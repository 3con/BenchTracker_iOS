//
//  WorkoutMilestone.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutMilestone.h"
#import "BTAchievement+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTUser+CoreDataClass.h"

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
                                    [BTAchievement numberOfUnreadAchievements]] importance:999999 type:WorkoutMilestoneTypeAchievement]];
    NSInteger numWorkouts = BTUser.sharedInstance.totalWorkouts;
    if (numWorkouts >= 3) {
        for (int i = 0; i < 3; i++) {
            NSArray<NSNumber *> *allTime = [workout allTimeRankForProperty:i];
            NSString *type;
            switch (i) {
                case 0:  type = @"most sets"; break;
                case 1:  type = @"largest volume"; break;
                default: type = @"longest workout"; break;
            }
            if (allTime[0].integerValue != -1) {
                [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%@ %@ of all-time",
                    [WorkoutMilestone formattedNumber:allTime], type]
                    importance:40-allTime[0].integerValue type:WorkoutMilestoneTypeWorkout]];
            }
            else {
                NSArray<NSNumber *> *thirtyDay = [workout thirtyDayRankForProperty:i];
                if (thirtyDay[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%@ %@ in the last 30-days",
                        [WorkoutMilestone formattedNumber:thirtyDay], type]
                        importance:22-thirtyDay[0].integerValue type:WorkoutMilestoneTypeWorkout]];
                }
            }
        }
    }
    for (BTExercise *exercise in workout.exercises) {
        if (exercise.numberOfSets != 0) {
            if (exercise.lastInstance == nil)
                [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New exercise:\n   %@ %@",
                    (exercise.iteration) ? exercise.iteration : @"", exercise.name] importance:19 type:WorkoutMilestoneTypeNewExercise]];
            else {
                NSArray<NSNumber *> *thirty = exercise.thirtyDayRank;
                NSArray<NSNumber *> *allTime = exercise.allTimeRank;
                if (allTime[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:
                                                                                 @"%@ best all-time 1RM equivalent:\n   %@ %@",
                        [WorkoutMilestone formattedNumber:allTime], (exercise.iteration) ? exercise.iteration : @"", exercise.name]
                        importance:20-allTime[0].integerValue-allTime[1].boolValue type:WorkoutMilestoneTypeTopExercise]];
                }
                else if (thirty[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:
                                                                                 @"%@ best 30-day 1RM equivalent:\n   %@ %@",
                        [WorkoutMilestone formattedNumber:thirty], (exercise.iteration) ? exercise.iteration : @"", exercise.name]
                        importance:10-thirty[0].integerValue-thirty[1].boolValue type:WorkoutMilestoneTypeTopExercise]];
                }
            }
        }
    }
    [milestones sortUsingComparator:^NSComparisonResult(WorkoutMilestone *obj1, WorkoutMilestone *obj2) {
        if (obj1.importance > obj2.importance) return NSOrderedAscending;
        if (obj1.importance < obj2.importance) return NSOrderedDescending;
        return NSOrderedSame;
    }];
    return milestones;
}

#pragma mark - helper method

+ (NSString *)formattedNumber:(NSArray<NSNumber *> *)arr {
    return [NSString stringWithFormat:@"%@%ld%@", arr[1].boolValue ? @"T-" : @"", arr.firstObject.integerValue,
            [@[@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th"] objectAtIndex:(arr.firstObject.integerValue % 10)]];
}

@end
