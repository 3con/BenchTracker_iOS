//
//  BTUser+CoreDataProperties.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataProperties.h"

@implementation BTUser (CoreDataProperties)

+ (NSFetchRequest<BTUser *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTUser"];
}

@dynamic dateCreated;
@dynamic name;
@dynamic imageData;
@dynamic weight;

@dynamic xp;
@dynamic achievementListVersion;

@dynamic totalDuration;
@dynamic totalVolume;
@dynamic totalWorkouts;
@dynamic totalSets;
@dynamic totalExercises;

@dynamic currentStreak;
@dynamic longestStreak;

@end
