//
//  WorkoutMilestone.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutMilestone.h"
#import "BTAchievement+CoreDataClass.h"

@implementation WorkoutMilestone

+ (WorkoutMilestone *) milestoneWithTitle:(NSString *)title
                               importance:(NSInteger)importance
                                     type:(WorkoutMilestoneType)type {
    WorkoutMilestone *milestone = [[WorkoutMilestone alloc] init];
    milestone.title = title;
    milestone.importance = importance;
    milestone.type = type;
    return milestone;
}

+ (NSArray <WorkoutMilestone *> *)milestonesForWorkout:(BTWorkout *)workout {
    NSMutableArray <WorkoutMilestone *> *milestones = @[].mutableCopy;
    if ([BTAchievement numberOfUnreadAchievements] != 0)
        [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%ld new achievements",
                                    [BTAchievement numberOfUnreadAchievements]] importance:999 type:WorkoutMilestoneTypeAchievement]];
    return milestones;
}

@end
