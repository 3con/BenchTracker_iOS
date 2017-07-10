//
//  BTRecentWorkoutsManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTRecentWorkoutsManager : NSObject

@property (nonatomic) NSInteger maxFetch;

- (id)init;

- (void)reloadData;

- (NSInteger)numberOfRecentWorkouts;

- (NSArray <NSString *> *)workoutNames;

- (NSArray <NSString *> *)workoutShortDates;

- (NSArray <NSString *> *)workoutDates;

- (NSDictionary <NSString *, NSNumber *> *)workoutExercises;

- (NSDictionary <NSString *, NSNumber *> *)workoutExerciseTypes;

- (NSArray <NSNumber *> *)workoutNumExercises;

- (NSArray <NSNumber *> *)workoutVolumes;

- (NSArray <NSNumber *> *)workoutDurations;

@end
