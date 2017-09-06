//
//  BTWorkout+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTExercise, BTUser;

NS_ASSUME_NONNULL_BEGIN

@interface BTWorkout : NSManagedObject

+ (BTWorkout *)workout;

+ (NSString *)jsonForWorkout:(BTWorkout *)workout;

+ (NSString *)jsonForTemplateWorkout:(BTWorkout *)workout;

+ (BTWorkout *)workoutForJSON: (NSString *)jsonString;

+ (void)resetWorkouts;

+ (NSArray <BTWorkout *> *)workoutsBetweenBeginDate:(NSDate *)d1 andEndDate:(NSDate *)d2;

+ (NSInteger)numberOfWorkouts;

+ (NSArray <BTWorkout *> *)allWorkoutsWithFactoredIntoTotalsFilter:(BOOL)factoredIntoTotalsFilter;

@end

NS_ASSUME_NONNULL_END

#import "BTWorkout+CoreDataProperties.h"
