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

#pragma mark - general methods

- (NSInteger)numberOfRecentWorkouts;

- (NSArray <NSString *> *)workoutNames;

- (NSArray <NSString *> *)workoutShortDates;

- (NSArray <NSString *> *)workoutDates;

#pragma mark - data methods

- (NSDictionary <NSString *, NSNumber *> *)workoutExercises;

- (NSString *)formattedFirstDayOfWeek;

- (NSDictionary <NSString *, NSNumber *> *)workoutExerciseTypesThisWeek;

- (NSArray <NSString *> *)otherDataThisWeek;

- (NSArray <NSNumber *> *)workoutVolumes;

- (NSArray <NSNumber *> *)workoutDurations;

- (NSArray <NSNumber *> *)workoutNumExercises;

- (NSArray <NSNumber *> *)workoutNumSets;

@end
