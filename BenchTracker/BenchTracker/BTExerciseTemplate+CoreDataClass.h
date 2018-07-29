//
//  BTExerciseTemplate+CoreDataClass.h
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTWorkoutTemplate;

NS_ASSUME_NONNULL_BEGIN

@class BTExercise;

@interface BTExerciseTemplate : NSManagedObject

+ (BTExercise *)exerciseForExerciseTemplate:(BTExerciseTemplate *)exerciseTemplate;

@end

NS_ASSUME_NONNULL_END

#import "BTExerciseTemplate+CoreDataProperties.h"
