//
//  BTWorkoutManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTWorkout+CoreDataClass.h"

@class BTWorkoutManager;

@protocol BTWorkoutManagerDelegate <NSObject>
@required
- (void) workoutManager:(BTWorkoutManager *)workoutManager didCreateWorkout:(BTWorkout *)workout;
- (void) workoutManager:(BTWorkoutManager *)workoutManager didEditWorkout:(BTWorkout *)workout;
- (void) workoutManager:(BTWorkoutManager *)workoutManager didDeleteWorkout:(BTWorkout *)workout;
@end

@interface BTWorkoutManager : NSObject

@property id<BTWorkoutManagerDelegate> delegate;

+ (id)sharedInstance;

//client -> server

- (BTWorkout *)createWorkout;

- (void)saveEditedWorkout: (BTWorkout *)workout;

- (void)deleteWorkout: (BTWorkout *)workout;

//server -> client

- (void)updateWorkoutsWithRecentEdits: (NSMutableArray<NSString *>*)recentEdits;

//client helpers

- (NSArray <BTWorkout *> *)workoutsBetweenBeginDate:(NSDate *)d1 andEndDate:(NSDate *)d2;

@end
