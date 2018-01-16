//
//  BTExerciseType+CoreDataProperties.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExerciseType+CoreDataProperties.h"

@implementation BTExerciseType (CoreDataProperties)

+ (NSFetchRequest<BTExerciseType *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTExerciseType"];
}

@dynamic name;
@dynamic category;
@dynamic style;
@dynamic iterations;

@end
