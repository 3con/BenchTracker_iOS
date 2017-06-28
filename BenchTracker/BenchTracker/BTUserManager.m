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

- (BTUser *)user {
    NSFetchRequest *request = [BTUser fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
    else if (object.count == 0) return nil;
    return object[0];
}

- (void)getAWSUser {
    BTUser *user = [self user];
    if(!user) return;
    [[self.mapper load:[BTAWSUser class] hashKey:user.username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else {
            if (task.result) { //user exists
                self.AWSUser = task.result;
            }
            else {
                [self pushUserToAWS];
            }
        }
        return nil;
    }];
}

- (void)createUserWithUsername: (NSString *)username {
    
}

- (void)pushUserToAWS {
    BTAWSUser *AWSUser = [BTAWSUser new];
    [[self.mapper save:AWSUser] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else {
            
        };
        return nil;
    }];
}

- (void)updateUserFromAWS {
    BTUser *user = [self user];
    if(!user) return;
    [self getAWSUser];
    //compare type list versions
    //compare recentEdits
}

@end
