//
//  BTWorkout+CoreDataProperties.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkout+CoreDataProperties.h"

@implementation BTWorkout (CoreDataProperties)

+ (NSFetchRequest<BTWorkout *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
}

@dynamic uuid;
@dynamic summary;
@dynamic date;
@dynamic duration;
@dynamic name;
@dynamic user;
@dynamic exercises;

@end
