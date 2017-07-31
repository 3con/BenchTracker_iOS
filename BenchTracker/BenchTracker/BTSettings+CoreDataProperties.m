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
@dynamic hiddenExerciseTypeSections;
@dynamic exerciseTypeColors;

@dynamic startWeekOnMonday;
@dynamic disableSleep;
@dynamic weightInLbs;

@end
