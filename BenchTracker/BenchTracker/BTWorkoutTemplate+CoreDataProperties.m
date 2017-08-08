//
//  BTWorkoutTemplate+CoreDataProperties.m
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTWorkoutTemplate+CoreDataProperties.h"

@implementation BTWorkoutTemplate (CoreDataProperties)

+ (NSFetchRequest<BTWorkoutTemplate *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTWorkoutTemplate"];
}

@dynamic name;
@dynamic supersets;
@dynamic uuid;
@dynamic summary;
@dynamic exercises;

@end
