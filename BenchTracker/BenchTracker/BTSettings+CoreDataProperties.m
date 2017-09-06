//
//  BTSettings+CoreDataProperties.m
//  
//
//  Created by Chappy Asel on 7/14/17.
//
//

#import "BTSettings+CoreDataProperties.h"

@implementation BTSettings (CoreDataProperties)

+ (NSFetchRequest<BTSettings *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTSettings"];
}

@dynamic activeWorkout;
@dynamic activeWorkoutStartDate;
@dynamic activeWorkoutLastUpdate;

@dynamic hiddenExerciseTypeSections;
@dynamic exerciseTypeColors;

@dynamic startWeekOnMonday;
@dynamic disableSleep;
@dynamic weightInLbs;

@dynamic showWorkoutDetails;
@dynamic showEquivalencyChart;
@dynamic showLastWorkout;

@dynamic bodyweightIsVolume;
@dynamic bodyweightMultiplier;

@end
