//
//  BTAWSUser.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface BTAWSUser : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nullable, nonatomic, copy)   NSString *username;
@property (nonatomic)                   NSNumber * _Nonnull typeListVersion;
@property (nullable, nonatomic, retain) NSMutableArray<NSString *> *recentEdits;
@property (nullable, nonatomic, retain) NSMutableArray<NSString *> *workouts;

@end
