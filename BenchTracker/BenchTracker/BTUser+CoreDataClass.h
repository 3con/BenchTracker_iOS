//
//  BTUser+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTWorkout;
@class AWSLeaderboard;

NS_ASSUME_NONNULL_BEGIN

@interface BTUser : NSManagedObject

@property (nonatomic) UIImage *image;

@property (nonatomic, readonly) NSInteger level;

@property (nonatomic, readonly) CGFloat levelProgress;

#pragma mark - client

+ (BTUser *)sharedInstance;

+ (void)removeWorkoutFromTotals:(BTWorkout *)workout;

+ (void)addWorkoutToTotals:(BTWorkout *)workout;

+ (void)checkForTotalsPurge;

+ (void)updateStreaks;

#pragma mark - server only

- (void)userExistsWithUsername:(NSString *)username continueWithBlock:(void (^)(BOOL exists))completed;

- (void)changeUserToUsername:(NSString *)username continueWithBlock:(void (^)(BOOL success))completed;

- (void)topLevelsWithCompletionBlock:(void (^)(NSArray<AWSLeaderboard *> *topLevels))completed;

@end

NS_ASSUME_NONNULL_END

#import "BTUser+CoreDataProperties.h"
