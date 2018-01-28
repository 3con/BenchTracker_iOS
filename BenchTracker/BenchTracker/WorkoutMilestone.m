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

//Achievement: 999
//AT Workout:  60-39
//AT Exercise: 35-24
//30 Workout:  22-11
//30 Exercise: 10-0
//New Exercse: 4

+ (NSArray <WorkoutMilestone *> *)milestonesForWorkout:(BTWorkout *)workout {
    NSMutableArray <WorkoutMilestone *> *milestones = @[].mutableCopy;
    long num = [BTAchievement numberOfUnreadAchievements];
    if (num != 0) [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%ld new achievement%@",
                     (long)num, (num == 1) ? @"" : @"s"] importance:999 type:WorkoutMilestoneTypeAchievement]];
    int64_t numWorkouts = BTUser.sharedInstance.totalWorkouts;
    [BTUser updateStreaks];
    BTUser *user = [BTUser sharedInstance];
    if (user.currentStreak >= 2) {
        if (user.currentStreak == user.longestStreak)
             [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New longest streak: %lld!",
                user.currentStreak] importance:998 type:WorkoutMilestoneTypeStreak]];
        else [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"Current streak: %lld\nLongest streak: %lld",
                user.currentStreak, user.longestStreak] importance:8+user.currentStreak*3 type:WorkoutMilestoneTypeStreak]];
    }
    
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
                    [WorkoutMilestone formattedNumber:allTime withBest:NO], type]
                    importance:60-allTime[0].integerValue*2-allTime[1].boolValue type:WorkoutMilestoneTypeWorkout]];
            }
            else {
                NSArray<NSNumber *> *thirtyDay = [workout thirtyDayRankForProperty:i];
                if (thirtyDay[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%@ %@ in the last 30 days",
                        [WorkoutMilestone formattedNumber:thirtyDay withBest:NO], type]
                        importance:22-thirtyDay[0].integerValue*2-thirtyDay[1].boolValue type:WorkoutMilestoneTypeWorkout]];
                }
            }
        }
    }
    for (BTExercise *exercise in workout.exercises) {
        if (exercise.numberOfSets != 0) {
            if (exercise.lastInstance == nil)
                [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New exercise:\n   %@ %@",
                    (exercise.iteration) ? exercise.iteration : @"", exercise.name] importance:4 type:WorkoutMilestoneTypeNewExercise]];
            else {
                NSArray<NSNumber *> *thirty = exercise.thirtyDayRank;
                NSArray<NSNumber *> *allTime = exercise.allTimeRank;
                if (allTime[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:
                                                                                 @"%@ all-time 1RM equivalent:\n   %@ %@",
                        [WorkoutMilestone formattedNumber:allTime withBest:YES], (exercise.iteration) ? exercise.iteration : @"", exercise.name]
                        importance:35-allTime[0].integerValue*2-allTime[1].boolValue type:WorkoutMilestoneTypeTopExercise]];
                }
                else if (thirty[0].integerValue != -1) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:
                                                                                 @"%@ 30-day 1RM equivalent:\n   %@ %@",
                        [WorkoutMilestone formattedNumber:thirty withBest:YES], (exercise.iteration) ? exercise.iteration : @"", exercise.name]
                        importance:10-thirty[0].integerValue*2-thirty[1].boolValue type:WorkoutMilestoneTypeTopExercise]];
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

+ (NSString *)formattedNumber:(NSArray<NSNumber *> *)arr withBest:(BOOL)best {
    return [NSString stringWithFormat:@"%@%ld%@%@", arr[1].boolValue ? @"T-" : @"", arr[0].integerValue,
               @[@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th"][arr[0].integerValue % 10],
               (best && arr[0].integerValue != 1) ? @" best" : @""];
}

@end
