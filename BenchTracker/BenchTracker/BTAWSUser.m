//
//  BTAWSUser.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTAWSUser.h"
#import "BenchTrackerKeys.h"

@implementation BTAWSUser

+ (NSString *)dynamoDBTableName {
    return AWS_USERS_TABLE_NAME;
}

+ (NSString *)hashKeyAttribute {
    return @"username";
}

@end
