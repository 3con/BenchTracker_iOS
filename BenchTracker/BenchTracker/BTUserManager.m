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

@property (nonatomic, strong) BTAWSUser *awsUser;

@property (nonatomic, strong) NSTimer *updateTimer;

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

- (void)addWorkoutToLocalUser:(BTWorkout *)workout {
    [[self user] addWorkoutsObject:workout];
}

#pragma mark - client -> server

- (void)createUserWithUsername: (NSString *)username completionBlock:(void (^)())completed {
    BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:self.context];
    user.username = username;
    user.dateCreated = [NSDate date];
    user.lastUpdate = [NSDate date];
    user.typeListVersion = 0;
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    user.workouts = [[NSOrderedSet alloc] initWithArray:@[]];
    self.awsUser = [self copyCDUser:[self user] toAWSUser:[BTAWSUser new]];
    [self pushAWSUserWithCompletionBlock:^{
        completed();
    }];
    [self saveCoreData];
}

#pragma mark - server -> client

- (void)setAutoRefresh:(BOOL)autoRefresh {
    if (autoRefresh) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self updateUserFromAWS];
        }];
    }
    else {
        [self.updateTimer invalidate];
    }
}

- (void)updateUserFromAWS {
    BTUser *user = [self user];
    if(!user) return;
    [self getAWSUserWithUsername:user.username completionBlock:^{
        if (!self.awsUser) { //user deleted from server
            self.awsUser = [self copyCDUser:[self user] toAWSUser:[BTAWSUser new]];
            [self pushAWSUserWithCompletionBlock:^{
                
            }];
        }
        //compare version -> typeListManager
        //compare workouts -> workoutmanager
        [self.workoutManager updateWorkoutsWithLocalRecentEdits:[NSKeyedUnarchiver unarchiveObjectWithData:user.recentEdits]
                                                 AWSRecentEdits:self.awsUser.recentEdits];
        user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.awsUser.recentEdits];
    }];
}

- (void)copyUserFromAWS: (NSString *)username completionBlock:(void (^)())completed {
    [self getAWSUserWithUsername:username completionBlock:^{
        BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:self.context];
        user = [self copyAWSUser:self.awsUser toCDUser:user];
        [self saveCoreData];
        completed();
    }];
}

#pragma mark - server only

- (void)userExistsWithUsername: (NSString *)username continueWithBlock:(void (^)(BOOL exists))completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManager get error: [%@]", task.error);
        else completed(task.result != nil);
        return nil;
    }];
}

#pragma mark - workoutManager delegate

- (void)workoutManager:(BTWorkoutManager *)workoutManager didCreateWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.awsUser.recentEdits.count == 1 && [self.awsUser.recentEdits containsObject:AWS_EMPTY])
        [self.awsUser.recentEdits removeAllObjects];
    [self.awsUser.recentEdits addObject:[NSString stringWithFormat:@"%d A %@",time,uuid]];
    if (self.awsUser.workouts.count == 1 && [self.awsUser.workouts containsObject:AWS_EMPTY])
        [self.awsUser.workouts removeAllObjects];
    [self.awsUser.workouts addObject:uuid];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.awsUser.recentEdits];
    [user addWorkoutsObject:workout];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

- (void)workoutManager:(BTWorkoutManager *)workoutManager didEditWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.awsUser.recentEdits.count == 1 && [self.awsUser.recentEdits containsObject:AWS_EMPTY])
        [self.awsUser.recentEdits removeAllObjects];
    [self.awsUser.recentEdits addObject:[NSString stringWithFormat:@"%d E %@",time,uuid]];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.awsUser.recentEdits];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

- (void)workoutManager:(BTWorkoutManager *)workoutManager didDeleteWorkout:(BTWorkout *)workout {
    NSString *uuid = workout.uuid;
    int time = 1999999999-[NSDate timeIntervalSinceReferenceDate];
    if (self.awsUser.recentEdits.count == 1 && [self.awsUser.recentEdits containsObject:AWS_EMPTY])
        [self.awsUser.recentEdits removeAllObjects];
    [self.awsUser.recentEdits addObject:[NSString stringWithFormat:@"%d D %@",time,uuid]];
    [self.awsUser.workouts removeObject:uuid];
    if (self.awsUser.workouts.count == 0) [self.awsUser.workouts addObject:AWS_EMPTY];
    BTUser *user = [self user];
    user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:self.awsUser.recentEdits];
    [user removeWorkoutsObject:workout];
    [self.context deleteObject:workout];
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

#pragma mark - typeListManager delegate

- (void)typeListManagerDidEditList:(BTTypeListManager *)typeListManager {
    self.awsUser.typeListVersion = [NSNumber numberWithInt:self.awsUser.typeListVersion.intValue + 1];
    BTUser *user = [self user];
    user.typeListVersion ++;
    [self saveCoreData];
    [self pushAWSUserWithCompletionBlock:^{
        
    }];
}

#pragma mark - private methods

- (void)getAWSUserWithUsername: (NSString *)username completionBlock:(void (^)())completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManager get error: [%@]", task.error);
        else {
            if (task.result) self.awsUser = task.result; //user exists
            else NSLog(@"AWS user not found");
            completed();
        }
        return nil;
    }];
}

- (void)pushAWSUserWithCompletionBlock:(void (^)())completed {
    self.awsUser.lastUpdate = [self stringForDate:[NSDate date]];
    [[self.mapper save:self.awsUser] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"userManager push error: [%@]", task.error);
        else completed();
        return nil;
    }];
}

- (BTAWSUser *)copyCDUser: (BTUser *)user toAWSUser: (BTAWSUser *)awsUser {
    awsUser.username = user.username;
    awsUser.dateCreated = [self stringForDate:user.dateCreated];
    awsUser.lastUpdate = [self stringForDate:user.lastUpdate];
    awsUser.typeListVersion = [NSNumber numberWithInt:user.typeListVersion];
    NSArray *rE = [NSKeyedUnarchiver unarchiveObjectWithData:user.recentEdits];
    awsUser.recentEdits = [[NSMutableArray alloc] initWithArray:(rE.count == 0) ? @[AWS_EMPTY] : rE];
    awsUser.workouts = [[NSMutableArray alloc] init];
    for (BTWorkout *workout in user.workouts) [awsUser.workouts addObject:workout.uuid];
    //<> Handle with recent edits instead
    if (user.workouts.count == 0) [awsUser.workouts addObject:AWS_EMPTY];
    return awsUser;
}

- (BTUser *)copyAWSUser: (BTAWSUser *)awsUser toCDUser: (BTUser *)user {
    user.username = awsUser.username;
    user.dateCreated = [self dateForString:awsUser.dateCreated];
    user.lastUpdate = [self dateForString:awsUser.lastUpdate];
    user.typeListVersion = awsUser.typeListVersion.intValue;
    if ([awsUser.recentEdits.firstObject isEqualToString:AWS_EMPTY])
        user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    else user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:awsUser.recentEdits];
    for (NSString *uuid in awsUser.workouts) {
        [self.workoutManager fetchWorkoutFromAWSWithUUID:uuid completionBlock:^(BTWorkout *workout) {
            if (workout) [user addWorkoutsObject:workout];
        }];
    }
    return user;
}

- (NSString *)stringForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}

- (NSDate *)dateForString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter dateFromString:string];
}

- (void)saveCoreData {
    NSError *error;
    [self.context save:&error];
    if(error) NSLog(@"userManager error: %@",error);
}

@end
