//
//  WorkoutMilestone.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum WorkoutMilestoneType : NSInteger {
    WorkoutMilestoneTypeAchievement,
    WorkoutMilestoneTypeWorkout,
    WorkoutMilestoneTypeLift
} WorkoutMilestoneType;

@class BTWorkout;

@interface WorkoutMilestone : NSObject

@property (nonatomic) NSString *title;
@property (nonatomic) WorkoutMilestoneType type;
@property (nonatomic) NSInteger importance;

+ (NSArray <WorkoutMilestone *> *)milestonesForWorkout:(BTWorkout *)workout;

@end
