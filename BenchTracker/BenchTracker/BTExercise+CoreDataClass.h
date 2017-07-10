//
//  BTExercise+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define STYLE_REPSWEIGHT @"repsWeight"
#define STYLE_REPS       @"reps"
#define STYLE_TIMEWEIGHT @"timeWeight"
#define STYLE_TIME       @"time"
#define STYLE_CUSTOM     @"custom"

@class BTWorkout;

NS_ASSUME_NONNULL_BEGIN

@interface BTExercise : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "BTExercise+CoreDataProperties.h"
