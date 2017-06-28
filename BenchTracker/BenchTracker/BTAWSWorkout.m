//
//  BTAWSWorkout.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTAWSWorkout.h"
#import "BenchTrackerKeys.h"

@implementation BTAWSWorkout

+ (NSString *)dynamoDBTableName {
    return AWS_WORKOUTS_TABLE_NAME;
}

+ (NSString *)hashKeyAttribute {
    return @"uuid";
}

@end
