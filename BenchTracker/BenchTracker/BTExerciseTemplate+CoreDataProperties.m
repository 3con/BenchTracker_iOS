//
//  BTExerciseTemplate+CoreDataProperties.m
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTExerciseTemplate+CoreDataProperties.h"

@implementation BTExerciseTemplate (CoreDataProperties)

+ (NSFetchRequest<BTExerciseTemplate *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTExerciseTemplate"];
}

@dynamic category;
@dynamic iteration;
@dynamic name;
@dynamic style;
@dynamic workout;

@end
