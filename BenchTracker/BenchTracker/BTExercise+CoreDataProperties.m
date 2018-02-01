//
//  BTExercise+CoreDataProperties.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExercise+CoreDataProperties.h"

@implementation BTExercise (CoreDataProperties)

+ (NSFetchRequest<BTExercise *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTExercise"];
}

@dynamic sets;
@dynamic oneRM;
@dynamic volume;
@dynamic style;
@dynamic name;
@dynamic iteration;
@dynamic category;
@dynamic workout;

@end
