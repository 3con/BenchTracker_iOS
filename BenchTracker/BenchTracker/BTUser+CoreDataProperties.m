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

@dynamic username;
@dynamic dateCreated;
@dynamic lastUpdate;
@dynamic typeListVersion;
@dynamic recentEdits;
@dynamic workouts;

@end
