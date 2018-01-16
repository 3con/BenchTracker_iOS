//
//  BTSettings+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 7/14/17.
//
//

#import "BTSettings+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@class BTWorkout;

@interface BTSettings (CoreDataProperties)

+ (NSFetchRequest<BTSettings *> *)fetchRequest;

@property (nullable, nonatomic, retain) BTWorkout *activeWorkout;
@property (nullable, nonatomic, copy)   NSDate *activeWorkoutStartDate;
@property (nullable, nonatomic, copy)   NSDate *activeWorkoutLastUpdate;
@property (nonatomic) int64_t activeWorkoutBeforeDuration;

@property (nullable, nonatomic, retain) NSData *hiddenExerciseTypeSections;
@property (nullable, nonatomic, retain) NSData *exerciseTypeColors;

@property (nonatomic) BOOL startWeekOnMonday;
@property (nonatomic) BOOL disableSleep;
@property (nonatomic) BOOL weightInLbs;

@property (nonatomic) BOOL showWorkoutDetails;
@property (nonatomic) BOOL showEquivalencyChart;
@property (nonatomic) BOOL showLastWorkout;

@property (nonatomic) BOOL bodyweightIsVolume;
@property (nonatomic) float bodyweightMultiplier;

@end

NS_ASSUME_NONNULL_END
