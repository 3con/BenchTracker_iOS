//
//  AWSLeaderboard.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSLeaderboard : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, nonnull) NSString *valid;
@property (nonatomic, nonnull) NSString *username;

@property (nonatomic, nonnull) NSNumber *experience;

@end
