//
//  AWSUsername.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/15/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AWSUsername.h"
#import "BenchTrackerKeys.h"

@implementation AWSUsername

+ (NSString *)dynamoDBTableName {
    return AWS_USERNAME_TABLE_NAME;
}

+ (NSString *)hashKeyAttribute {
    return @"username";
}

@end
