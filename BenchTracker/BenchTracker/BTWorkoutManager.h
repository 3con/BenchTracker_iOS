//
//  BTWorkoutManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTWorkout+CoreDataClass.h"

@interface BTWorkoutManager : NSObject

+ (id)sharedInstance;

//client -> server

- (BTWorkout *)createWorkout;

- (void)saveEditedWorkout: (BTWorkout *)workout;

- (void)deleteWorkout: (BTWorkout *)workout;

//server -> client

- (void)updateWorkoutsWithRecentEdits: (NSMutableArray<NSString *>*)recentEdits;

@end
