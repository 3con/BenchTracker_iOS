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
//Streak long: 998

//AT Workout:  <60-150> - 2x<1-20> - 5t
//30 Workout:  <20-50>  - 2x<1-10> - 5t

//AT Exercise: <27-65>  - 2x<1-10> - 4t
//30 Exercise: <24-40>  - 2x<1-5>  - 4t

//Streak:      5 + 2x
//New Exercse: 1

+ (NSArray <WorkoutMilestone *> *)milestonesForWorkout:(BTWorkout *)workout {
    BTUser *user = [BTUser sharedInstance];
    NSMutableArray <WorkoutMilestone *> *milestones = @[].mutableCopy;
    
    //WORKOUT RANK
    if (user.totalWorkouts >= 3) {
        for (int i = 0; i < 3; i++) {
            BTWorkoutRank allTime = [workout rankForProperty:i timeSpan:BTWorkoutTimeSpanTypeAllTime];
            NSString *type;
            switch (i) {
                case 0:  type = @"most sets"; break;
                case 1:  type = @"largest workout volume"; break;
                default: type = @"longest workout"; break;
            }
            BOOL impressive = allTime.rank <= MIN(20, allTime.total/5);
            if (allTime.rank != -1 && allTime.numTied < 8 && impressive) {
                [milestones addObject: [WorkoutMilestone milestoneWithTitle:
                    [NSString stringWithFormat:@"%@ %@ of all-time", [WorkoutMilestone formattedWorkoutRank:allTime], type]
                        importance:50+MAX(10, MIN(100, user.totalWorkouts))-allTime.rank*2-allTime.numTied*5
                              type:WorkoutMilestoneTypeWorkout]];
            }
            else {
                BTWorkoutRank thirtyDay = [workout rankForProperty:i timeSpan:BTWorkoutTimeSpanType30Day];
                BOOL impressive = thirtyDay.rank <= MIN(10, thirtyDay.total/3);
                if (thirtyDay.rank != -1 && thirtyDay.total > 1 && thirtyDay.numTied < 5 && impressive) {
                    [milestones addObject: [WorkoutMilestone milestoneWithTitle:
                        [NSString stringWithFormat:@"%@ %@ in the last 30 days", [WorkoutMilestone formattedWorkoutRank:thirtyDay], type]
                            importance:20+MAX(10, MIN(30, thirtyDay.total))-thirtyDay.rank*2-thirtyDay.numTied*5
                                  type:WorkoutMilestoneTypeWorkout]];
                }
            }
        }
    }
    if (milestones.count >= 3) { //Only up to 2 workout-related milestones
        WorkoutMilestone *low = milestones.firstObject;
        for (int i = 1; i < milestones.count; i++)
            low = (low.importance > milestones[i].importance) ? milestones[i] : low;
        [milestones removeObject:low];
    }
    
    //ACHIEVEMENTS
    long num = [BTAchievement numberOfUnreadAchievements];
    if (num != 0) [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"%ld new achievement%@",
                     (long)num, (num == 1) ? @"" : @"s"] importance:999 type:WorkoutMilestoneTypeAchievement]];
    
    //STREAKS
    [BTUser updateStreaks];
    if (user.currentStreak >= 2) {
        if (user.currentStreak == user.longestStreak) {
            if (user.currentStreak > 4)
                 [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New longest streak: %lld!",
                                                                             user.currentStreak] importance:998 type:WorkoutMilestoneTypeStreak]];
            else [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New longest streak: %lld!",
                                                                              user.currentStreak] importance:20 type:WorkoutMilestoneTypeStreak]];
        }
        else [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"Current streak: %lld\nLongest streak: %lld",
                user.currentStreak, user.longestStreak] importance:5+user.currentStreak*3 type:WorkoutMilestoneTypeStreak]];
    }
    
    //EXERCISE RANK
    for (BTExercise *exercise in workout.exercises) {
        if (exercise.numberOfSets != 0) {
            if (exercise.lastInstance == nil)
                [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat:@"New exercise:\n   %@ %@",
                    (exercise.iteration) ? exercise.iteration : @"", exercise.name] importance:1 type:WorkoutMilestoneTypeNewExercise]];
            else {
                for (int i = 0; i < 2; i++) {
                    if (i == 1 && ![exercise.style isEqualToString:STYLE_REPSWEIGHT]) continue;
                    BTExerciseRank allTime = [exercise rankForProperty:i timeSpan:BTExerciseTimeSpanTypeAllTime];
                    BOOL impressive = allTime.rank <= MIN(10, allTime.total/3);
                    if (allTime.rank != -1 && allTime.total > 4 && allTime.numTied < 8 && impressive) {
                        NSString *t = i ? @"exercise volume" : @"1RM equivalent";
                        [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat: @"%@ all-time %@:\n   %@ %@",
                            [WorkoutMilestone formattedExerciseRank:allTime], t, (exercise.iteration)?exercise.iteration:@"",exercise.name]
                                importance:25+MAX(2, MIN(40, allTime.total))-allTime.rank*2-allTime.numTied*4
                                      type:i ? WorkoutMilestoneTypeVolumeExercise : WorkoutMilestoneTypeOneRMExercise]];
                    }
                    else {
                        BTExerciseRank thirtyDay = [exercise rankForProperty:i timeSpan:BTExerciseTimeSpanType30Day];
                        BOOL impressive = thirtyDay.rank <= MIN(5, thirtyDay.total/2);
                        if (thirtyDay.rank != -1 && thirtyDay.total > 1 && thirtyDay.numTied < 5 && impressive) {
                            NSString *t = i ? @"exercise volume" : @"1RM equivalent";
                            [milestones addObject: [WorkoutMilestone milestoneWithTitle:[NSString stringWithFormat: @"%@ 30-day %@:\n   %@ %@",
                                [WorkoutMilestone formattedExerciseRank:thirtyDay], t, (exercise.iteration)?exercise.iteration:@"",exercise.name]
                                    importance:22+MAX(2, MIN(20, thirtyDay.total))-thirtyDay.rank*2-thirtyDay.numTied*4
                                          type:i ? WorkoutMilestoneTypeVolumeExercise : WorkoutMilestoneTypeOneRMExercise]];
                        }
                    }
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

+ (NSString *)formattedWorkoutRank:(BTWorkoutRank)wr {
    if (wr.rank == 1 && wr.numTied == 0) return @"#1";
    return [NSString stringWithFormat:@"%@%ld%@", (wr.numTied > 0) ? @"T-" : @"", wr.rank,
               @[@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th"][wr.rank % 10]];
}

+ (NSString *)formattedExerciseRank:(BTExerciseRank)er {
    if (er.rank == 1 && er.numTied == 0) return @"#1";
    return [NSString stringWithFormat:@"%@%ld%@", (er.numTied > 0) ? @"T-" : @"", er.rank,
            @[@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th"][er.rank % 10]];
}

@end
