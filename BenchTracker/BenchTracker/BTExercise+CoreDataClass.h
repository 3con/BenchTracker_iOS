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

NS_ASSUME_NONNULL_BEGIN

@class BTWorkout;

@interface BTExercise : NSManagedObject

@property (nonatomic) NSInteger numberOfSets;

@property (nonatomic) CGFloat volume;

- (void)calculateOneRM;

- (BTExercise *)lastInstance; //last instance (excluding this one)

@end

NS_ASSUME_NONNULL_END

#import "BTExercise+CoreDataProperties.h"
