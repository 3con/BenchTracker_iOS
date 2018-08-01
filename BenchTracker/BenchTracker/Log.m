//
//  Log.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "Log.h"
#import "Amplitude.h"
#import "BTSettings+CoreDataClass.h"
#import "BTUser+CoreDataClass.h"

@implementation Log

+ (void)sendIdentity {
    BTUser *user = BTUser.sharedInstance;
    BTSettings *settings = BTSettings.sharedInstance;
    NSDictionary *properties = @{@"User":     @{@"Date created": user.dateCreated,
                                                @"Username": (user.name == nil) ? @"<NULL>" : user.name,
                                                @"Weight": @(user.weight),
                                                @"Achievement list version": @(user.achievementListVersion),
                                                @"Experience": @(user.xp),
                                                @"Total duration": @(user.totalDuration),
                                                @"Total volume": @(user.totalVolume),
                                                @"Total workouts": @(user.totalWorkouts),
                                                @"Total sets": @(user.totalSets),
                                                @"Total exercises": @(user.totalExercises),
                                                @"Current streak": @(user.currentStreak),
                                                @"Longest streak": @(user.longestStreak)},
                                 @"Settings": @{@"Active workout": @(settings.activeWorkout != nil),
                                                @"Show smart names": @(settings.showSmartNames),
                                                @"Smart nicknames": (settings.smartNicknameDict == nil) ? @"<NULL>" : settings.smartNicknameDict,
                                                @"Start week on monday": @(settings.startWeekOnMonday),
                                                @"Disable sleep": @(settings.disableSleep),
                                                @"Weight in lbs": @(settings.weightInLbs),
                                                @"Show workout details": @(settings.showWorkoutDetails),
                                                @"Show equivalency chart": @(settings.showEquivalencyChart),
                                                @"Show last workout": @(settings.showLastWorkout),
                                                @"Bodyweight is volume": @(settings.bodyweightIsVolume),
                                                @"Bodyweight multiplier": @(settings.bodyweightMultiplier)}};
    [Amplitude.instance setUserProperties:properties];
}

+ (void)event:(NSString *)event properties:(NSDictionary *)properties {
    [Amplitude.instance logEvent:event withEventProperties:properties];
}

@end
