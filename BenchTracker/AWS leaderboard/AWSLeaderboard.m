//
//  AWSLeaderboard.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AWSLeaderboard.h"
#import "BenchTrackerKeys.h"

@implementation AWSLeaderboard

+ (NSString *)dynamoDBTableName {
    return AWS_LEADERBOARD_TABLE_NAME;
}

+ (NSString *)hashKeyAttribute {
    return @"valid";
}

+ (NSString *)rangeKeyAttribute {
    return @"username";
}

@end
