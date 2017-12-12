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

NS_ASSUME_NONNULL_BEGIN

@class BTWorkout;

@interface BTExercise : NSManagedObject

@property (nonatomic, readonly) NSInteger numberOfSets;

@property (nonatomic, readonly) CGFloat volume;

- (void)calculateOneRM;

- (BTExercise *)lastInstance; //last instance (excluding this one)

- (NSArray<NSNumber *> *)allTimeRank; //[0]: (int) lift's rank in all instances (1-5, else -1)
                                      //[1]: (BOOL) is tied

- (NSArray<NSNumber *> *)thirtyDayRank; //[0]: (int) lift's rank in instances last 30 days (1-5, else -1)
                                        //[1]: (BOOL) is tied

+ (NSInteger)oneRMForExerciseName:(NSString *)name;

+ (NSInteger)powerliftingTotalWeight;

@end

NS_ASSUME_NONNULL_END

#import "BTExercise+CoreDataProperties.h"
