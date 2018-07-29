//
//  BTExercise+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define STYLE_REPSWEIGHT @"repsWeight"
#define STYLE_REPS       @"reps"
#define STYLE_TIMEWEIGHT @"timeWeight"
#define STYLE_TIME       @"time"
#define STYLE_CUSTOM     @"custom"

typedef enum BTExercisePropertyType : NSInteger {
    BTExercisePropertyTypeOneRM  = 0,
    BTExercisePropertyTypeVolume = 1
} BTExercisePropertyType;

typedef enum BTExerciseTimeSpanType : NSInteger {
    BTExerciseTimeSpanType30Day   = 0,
    BTExerciseTimeSpanTypeAllTime = 1
} BTExerciseTimeSpanType;

typedef struct {
    NSInteger rank; //ranking of oneRM
    NSInteger total; //total exercises in span
    NSInteger numTied; //number of oneRMs tied
} BTExerciseRank;

NS_ASSUME_NONNULL_BEGIN

@class BTWorkout;
@class BTExerciseType;

@interface BTExercise : NSManagedObject

@property (nonatomic, readonly) NSInteger numberOfSets;

+ (BTExercise *)exerciseForExerciseType:(BTExerciseType *)type iteration:(id)iteration;

- (void)calculateOneRM;

- (BTExercise *)lastInstance; //last instance (excluding this one)

- (BTExerciseRank)rankForProperty:(BTExercisePropertyType)property timeSpan:(BTExerciseTimeSpanType)timeSpan;

- (void)calculateVolume;

+ (void)calculateAllVolumes;

+ (NSInteger)oneRMForExerciseName:(NSString *)name;

+ (NSInteger)powerliftingTotalWeight;

@end

NS_ASSUME_NONNULL_END

#import "BTExercise+CoreDataProperties.h"
