//
//  BTAchievement+CoreDataProperties.m
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import "BTAchievement+CoreDataProperties.h"

@implementation BTAchievement (CoreDataProperties)

+ (NSFetchRequest<BTAchievement *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTAchievement"];
}

@dynamic name;
@dynamic details;
@dynamic key;
@dynamic xp;
@dynamic completed;
@dynamic hidden;
@dynamic colorData;

@end
