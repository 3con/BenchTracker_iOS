//
//  BTAWSWorkout.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface BTAWSWorkout : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, nonnull)                   NSString* uuid;
@property (nonatomic, nonnull)                   NSString* name;
@property (nonatomic, nonnull)                   NSString* date;
@property (nonatomic, nonnull)                   NSNumber* duration;
@property (nonatomic, nonnull)                   NSString* summary;
@property (nonatomic, nonnull) NSMutableArray<NSString *>* exercises;

@end
