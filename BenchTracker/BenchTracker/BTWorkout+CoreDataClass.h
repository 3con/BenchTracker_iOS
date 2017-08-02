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

+ (BTWorkout *)createWorkout;

+ (NSArray <BTWorkout *> *)workoutsBetweenBeginDate:(NSDate *)d1 andEndDate:(NSDate *)d2;

+ (NSString *)jsonForWorkout:(BTWorkout *)workout;

+ (NSString *)jsonForTemplateWorkout:(BTWorkout *)workout;

+ (BTWorkout *)createWorkoutWithJSON: (NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END

#import "BTWorkout+CoreDataProperties.h"
