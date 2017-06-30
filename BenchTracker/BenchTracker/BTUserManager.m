//
//  BTUserManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUserManager.h"
#import "BTUser+CoreDataClass.h"
#import "BTAWSUser.h"
#import "AppDelegate.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "BenchTrackerKeys.h"
#import "BTWorkoutManager.h"
#import "BTTypeListManager.h"

@interface BTUserManager ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *mapper;
@property (nonatomic, strong) NSManagedObjectContext *context;

@property (nonatomic, strong) BTWorkoutManager *workoutManager;
@property (nonatomic, strong) BTTypeListManager *typeListManager;

@property (nonatomic, strong) BTAWSUser *AWSUser;

@end

@implementation BTUserManager

+ (id)sharedInstance {
    static BTUserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        sharedInstance.mapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        sharedInstance.workoutManager = [BTWorkoutManager sharedInstance];
        sharedInstance.workoutManager.delegate = sharedInstance;
        sharedInstance.typeListManager.delegate = sharedInstance;
    });
    return sharedInstance;
}

#pragma mark - client only

- (BTUser *)user {
    NSFetchRequest *request = [BTUser fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"userManager CoreData error: %@",error);
    else if (object.count == 0) return nil;
    return object[0];
}

#pragma mark - client -> server

- (void)createUserWithUsername: (NSString *)username completionBlock:(void (^)())completed {
    BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:self.context];
    user.username = username;
    user.typeListVersion = 0;
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    user.workouts = [[NSOrderedSet alloc] initWithArray:@[]];
    self.AWSUser = [self copyCDUser:[self user] toAWSUser:[BTAWSUser new]];
    [self pushAWSUserWithCompletionBlock:^{
        completed();
    }];
}

#pragma mark - server -> client

- (void)updateUserFromAWS {
    BTUser *user = [self user];
    if(!user) return;
    [self getAWSUserWithUsername:user.username completionBlock:^{
        if (!self.AWSUser) { //user deleted from server
            self.AWSUser = [self copyCDUser:[self user] toAWSUser:[BTAWSUser new]];
            [self pushAWSUserWithCompletionBlock:^{
                
            }];
        }
        //compare version -> typeListManager
        //compare workouts -> workoutmanager
    }];
}

- (void)copyUserFromAWS: (NSString *)username completionBlock:(void (^)())completed {
    [self getAWSUserWithUsername:username completionBlock:^{
        BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:self.context];
        user = [self copyAWSUser:self.AWSUser toCDUser:user];
        [self saveCoreData];
        completed();
    }];
}

#pragma mark - server only

- (void)userExistsWithUsername: (NSString *)username continueWithBlock:(void (^)(BOOL exists))completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManaer get error: [%@]", task.error);
        else completed(task.result != nil);
        return nil;
    }];
}

#pragma mark - workoutManager delegate

- (void)workoutManager:(BTWorkoutManager *)workoutManager didCreateWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.AWSUser.recentEdits.count == 1 && [self.AWSUser.recentEdits containsObject:AWS_EMPTY])
        [self.AWSUser.recentEdits removeAllObjects];
    [self.AWSUser.recentEdits addObject:[NSString stringWithFormat:@"%d A %@",time,uuid]];
    if (self.AWSUser.workouts.count == 1 && [self.AWSUser.workouts containsObject:AWS_EMPTY])
        [self.AWSUser.workouts removeAllObjects];
    [self.AWSUser.workouts addObject:uuid];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.AWSUser.recentEdits];
    [user addWorkoutsObject:workout];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

- (void)workoutManager:(BTWorkoutManager *)workoutManager didEditWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.AWSUser.recentEdits.count == 1 && [self.AWSUser.recentEdits containsObject:AWS_EMPTY])
        [self.AWSUser.recentEdits removeAllObjects];
    [self.AWSUser.recentEdits addObject:[NSString stringWithFormat:@"%d E %@",time,uuid]];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.AWSUser.recentEdits];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

- (void)workoutManager:(BTWorkoutManager *)workoutManager didDeleteWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.AWSUser.recentEdits.count == 1 && [self.AWSUser.recentEdits containsObject:AWS_EMPTY])
        [self.AWSUser.recentEdits removeAllObjects];
    [self.AWSUser.recentEdits addObject:[NSString stringWithFormat:@"%d D %@",time,uuid]];
    [self.AWSUser.workouts removeObject:uuid];
    if (self.AWSUser.workouts.count == 0) [self.AWSUser.workouts addObject:AWS_EMPTY];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.AWSUser.recentEdits];
    [user removeWorkoutsObject:workout];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

#pragma mark - typeListManager delegate

- (void)typeListManagerDidEditList:(BTTypeListManager *)typeListManager {
    self.AWSUser.typeListVersion = [NSNumber numberWithInt:self.AWSUser.typeListVersion.intValue + 1];
    BTUser *user = [self user];
    user.typeListVersion ++;
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

#pragma mark - private methods

- (void)getAWSUserWithUsername: (NSString *)username completionBlock:(void (^)())completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManaer get error: [%@]", task.error);
        else {
            if (task.result) self.AWSUser = task.result; //user exists
            else NSLog(@"AWS user not found");
            completed();
        }
        return nil;
    }];
}

- (void)pushAWSUserWithCompletionBlock:(void (^)())completed {
    [[self.mapper save:self.AWSUser] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManaer push error: [%@]", task.error);
        else completed();
        return nil;
    }];
}

- (BTAWSUser *)copyCDUser: (BTUser *)user toAWSUser: (BTAWSUser *)AWSUser {
    AWSUser.username = user.username;
    AWSUser.typeListVersion = [NSNumber numberWithInt:user.typeListVersion];
    NSArray *rE = [NSKeyedUnarchiver unarchiveObjectWithData:user.recentEdits];
    AWSUser.recentEdits = [[NSMutableArray alloc] initWithArray:(rE.count == 0) ? @[AWS_EMPTY] : rE];
    AWSUser.workouts = [[NSMutableArray alloc] init];
    for (BTWorkout *workout in user.workouts) [AWSUser.workouts addObject:workout.uuid];
    //<> Handle with recent edits instead
    if (user.workouts.count == 0) [AWSUser.workouts addObject:AWS_EMPTY];
    return AWSUser;
}

- (BTUser *)copyAWSUser: (BTAWSUser *)AWSUser toCDUser: (BTUser *)user {
    user.username = AWSUser.username;
    user.typeListVersion = AWSUser.typeListVersion.intValue;
    if ([AWSUser.recentEdits.firstObject isEqualToString:AWS_EMPTY])
        user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    else user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:AWSUser.recentEdits];
    //Handle workouts
    return user;
}

- (void)saveCoreData {
    NSError *error;
    [self.context save:&error];
    if(error) NSLog(@"userManager error: %@",error);
}

@end
