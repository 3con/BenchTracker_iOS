//
//  BTAWSUser.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface BTAWSUser : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, nonnull)                   NSString* username;
@property (nonatomic, nonnull)                   NSString* dateCreated;
@property (nonatomic, nonnull)                   NSString* lastUpdate;
@property (nonatomic, nonnull)                   NSNumber* typeListVersion;
@property (nonatomic, nonnull) NSMutableArray<NSString *>* recentEdits;
@property (nonatomic, nonnull) NSMutableArray<NSString *>* workouts;

@end
