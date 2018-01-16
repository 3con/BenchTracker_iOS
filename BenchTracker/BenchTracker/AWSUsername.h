//
//  AWSUsername.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/15/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSUsername : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, nonnull) NSString *deviceID;
@property (nonatomic, nonnull) NSString *username;

@property (nonatomic, nonnull) NSString *dateCreated;
@property (nonatomic, nonnull) NSString *lastUpdate;

@end
