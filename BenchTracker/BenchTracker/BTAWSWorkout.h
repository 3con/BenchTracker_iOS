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
@property (nonatomic, nonnull)                   NSNumber* volume;
@property (nonatomic, nonnull)                   NSNumber* numExercises;
@property (nonatomic, nonnull)                   NSNumber* numSets;
@property (nonatomic, nonnull)                   NSString* summary;   //"1 biceps#2 legs#..."
@property (nonatomic, nonnull) NSMutableArray<NSString *>* supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic, nonnull) NSMutableArray<NSString *>* exercises;

@end
