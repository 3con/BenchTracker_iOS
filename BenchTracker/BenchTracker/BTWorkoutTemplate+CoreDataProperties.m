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

@dynamic source;
@dynamic name;
@dynamic uuid;
@dynamic supersets;
@dynamic summary;
@dynamic exercises;

@end
