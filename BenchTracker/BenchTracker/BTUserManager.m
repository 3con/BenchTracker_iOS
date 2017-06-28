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
#import "BTWorkout+CoreDataClass.h"
#import "AppDelegate.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "BenchTrackerKeys.h"

#define AWS_EMPTY @"<EMPTY>"

@interface BTUserManager ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *mapper;
@property (nonatomic, strong) NSManagedObjectContext *context;

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
    });
    return sharedInstance;
}

#pragma mark - client only

- (BTUser *)user {
    NSFetchRequest *request = [BTUser fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
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
    [self pushUserToAWSWithCompletionBlock:^{
        completed();
    }];
}

#pragma mark - server -> client

- (void)updateUserFromAWS {
    BTUser *user = [self user];
    if(!user) return;
    //[self getAWSUser];
    //compare version -> typeListManager
    //compare workouts -> workoutmanager
}

- (void)copyUserFromAWS: (NSString *)username completionBlock:(void (^)())completed {
    [self getAWSUserWithUsername:username completionBlock:^{
        BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:self.context];
        user = [self copyAWSUser:self.AWSUser toCDUser:user];
        [self.context save:nil];
        completed();
    }];
}

#pragma mark - server only

- (void)userExistsWithUsername: (NSString *)username continueWithBlock:(void (^)(BOOL exists))completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else completed(task.result);
        return nil;
    }];
}

#pragma mark - private methods

- (void)getAWSUserWithUsername: (NSString *)username completionBlock:(void (^)())completed {
    [[self.mapper load:[BTAWSUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else {
            if (task.result) { //user exists
                self.AWSUser = task.result;
                completed();
            }
            else NSLog(@"AWS user not found");
        }
        return nil;
    }];
}

- (void)pushUserToAWSWithCompletionBlock:(void (^)())completed {
    BTAWSUser *AWSUser = [self copyCDUser:[self user] toAWSUser:[BTAWSUser new]];
    [[self.mapper save:AWSUser] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
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
    if (user.workouts.count == 0) [AWSUser.workouts addObject:AWS_EMPTY];
    return AWSUser;
}

- (BTUser *)copyAWSUser: (BTAWSUser *)AWSUser toCDUser: (BTUser *)user {
    user.username = AWSUser.username;
    user.typeListVersion = AWSUser.typeListVersion.intValue;
    if ([AWSUser.recentEdits.firstObject isEqualToString:AWS_EMPTY])
        user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:@[]];
    else user.recentEdits = [NSKeyedArchiver archivedDataWithRootObject:AWSUser.recentEdits];
    return user;
}

@end
