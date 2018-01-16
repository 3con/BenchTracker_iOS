//
//  BTWorkoutTemplate+CoreDataClass.h
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define TEMPLATE_SOURCE_USER @"User"
#define TEMPLATE_SOURCE_DEFAULT @"Default"

@class BTTemplateListModel;
@class BTWorkout;

NS_ASSUME_NONNULL_BEGIN

@interface BTWorkoutTemplate : NSManagedObject

+ (void)checkForExistingTemplateList;

+ (BTTemplateListModel *)templateListModel;

+ (void)resetTemplateList;

+ (void)loadTemplateListModel:(BTTemplateListModel *)model;

+ (BOOL)templateExistsForWorkout:(BTWorkout *)workout;

+ (void)saveWorkoutToTemplateList:(BTWorkout *)workout;

+ (void)removeWorkoutFromTemplateList:(BTWorkout *)workout;

+ (BTWorkout *)workoutForWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate;

@end

NS_ASSUME_NONNULL_END

#import "BTWorkoutTemplate+CoreDataProperties.h"
