//
//  BTSettings+CoreDataProperties.m
//  
//
//  Created by Chappy Asel on 7/1/17.
//
//

#import "BTSettings+CoreDataProperties.h"

@implementation BTSettings (CoreDataProperties)

+ (NSFetchRequest<BTSettings *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"BTSettings"];
}

@dynamic exerciseTypeColors;

@end
