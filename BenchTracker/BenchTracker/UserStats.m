//
//  UserStats.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/15/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UserStats.h"
#import "AppDelegate.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTUser+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

@interface UserStats ()

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSMutableArray *statTitles;
@property (nonatomic) NSMutableArray *statDetails;

@end

@implementation UserStats

+ (UserStats *)statsWithUser:(BTUser *)user settings:(BTSettings *)settings {
    UserStats *stats = [[UserStats alloc] init];
    stats.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    stats.statTitles = @[].mutableCopy;
    stats.statDetails = @[].mutableCopy;
    
    stats.statTitles[0] = @"Total Workouts";
    stats.statDetails[0] = [NSString stringWithFormat:@"%lld", user.totalWorkouts];
    
    stats.statTitles[1] = @"Workout %";
    stats.statDetails[1] = [NSString stringWithFormat:@"%.0f %%",
                            ((float)user.totalWorkouts)/([[NSDate date] timeIntervalSinceDate:user.dateCreated]/86400+1)*100];
    
    stats.statTitles[2] = @"Total Duration";
    stats.statDetails[2] = (user.totalDuration < 100*3600.0) ? [NSString stringWithFormat:@"%.1f hrs", user.totalDuration/3600.0]:
                                                               [NSString stringWithFormat:@"%.0f hrs", user.totalDuration/3600.0];
    
    stats.statTitles[3] = @"Total Volume";
    stats.statDetails[3] = (user.totalVolume < 1000000) ? [NSString stringWithFormat:@"%lldk %@", user.totalVolume/1000, settings.weightSuffix] :
                                                          [NSString stringWithFormat:@"%.2fm %@", user.totalVolume/1000000.0, settings.weightSuffix];
    
    stats.statTitles[4] = @"Total Sets";
    stats.statDetails[4] = (user.totalSets < 1000) ?  [NSString stringWithFormat:@"%lld", user.totalSets] :
                           (user.totalSets < 10000) ? [NSString stringWithFormat:@"%.2fk", user.totalSets/1000.0] :
                                                      [NSString stringWithFormat:@"%.1fk", user.totalSets/1000.0];
    
    stats.statTitles[5] = @"Longest Streak";
    stats.statDetails[5] = [NSString stringWithFormat:@"%lld day%@", user.longestStreak, (user.longestStreak == 1) ? @"" : @"s"];
    
    stats.statTitles[6] = @"Total Exercises";
    stats.statDetails[6] = (user.totalExercises < 1000) ?  [NSString stringWithFormat:@"%lld", user.totalExercises] :
                           (user.totalExercises < 10000) ? [NSString stringWithFormat:@"%.2fk", user.totalExercises/1000.0] :
                                                           [NSString stringWithFormat:@"%.1fk", user.totalExercises/1000.0];
    
    stats.statTitles[7] = @"Current Streak";
    stats.statDetails[7] = [NSString stringWithFormat:@"%lld day%@", user.currentStreak, (user.currentStreak == 1) ? @"" : @"s"];
    
    stats.statTitles[8] = @"Average Set";
    stats.statDetails[8] = (user.totalSets) ?
                                [NSString stringWithFormat:@"%.1f min", user.totalDuration / (float)user.totalSets / 60.0] : @"N/A";
    
    stats.statTitles[9] = @"Average Set";
    long long avg = (user.totalSets) ? user.totalVolume / user.totalSets : 0;
    stats.statDetails[9] = (avg < 1000) ? [NSString stringWithFormat:@"%lld %@", avg, settings.weightSuffix] :
                                          [NSString stringWithFormat:@"%.2fk %@", avg/1000.0, settings.weightSuffix];
    
    stats.statTitles[10] = @"Average Exercise";
    stats.statDetails[10] = (user.totalExercises) ?
                                [NSString stringWithFormat:@"%.1f min", user.totalDuration / (float)user.totalExercises / 60.0] : @"N/A";
    
    stats.statTitles[11] = @"Average Exercise";
    stats.statDetails[11] = (user.totalExercises) ?
                                [NSString stringWithFormat:@"%.2f sets", user.totalSets / (float)user.totalExercises] : @"N/A";
    
    stats.statTitles[12] = @"Volume Per Hour";
    stats.statDetails[12] = (user.totalDuration) ? [NSString stringWithFormat:@"%.1fk %@",
                                                    user.totalVolume/1000.0/user.totalDuration*3600, settings.weightSuffix] : @"N/A";
    
    stats.statTitles[13] = @"Powerlifting Total";
    stats.statDetails[13] = (BTExercise.powerliftingTotalWeight > 0) ? [NSString stringWithFormat:@"%ld %@",
                                BTExercise.powerliftingTotalWeight, settings.weightSuffix] : @"N/A";
    
    stats.statTitles[14] = @"Average Duration";
    stats.statDetails[14] = (user.totalWorkouts) ? [NSString stringWithFormat:@"%.1f min",
                                                    user.totalDuration/60.0/user.totalWorkouts] : @"N/A";

    stats.statTitles[15] = @"Average Volume";
    stats.statDetails[15] = (user.totalWorkouts) ? [NSString stringWithFormat:@"%.1fk %@",
                                                    user.totalVolume/1000.0/user.totalWorkouts, settings.weightSuffix] : @"N/A";
    
    stats.statTitles[16] = @"Average # Sets";
    stats.statDetails[16] = (user.totalWorkouts) ? [NSString stringWithFormat:@"%.2f", user.totalSets/(float)user.totalWorkouts] : @"N/A";
    
    stats.statTitles[17] = @"Average # Exercises";
    stats.statDetails[17] = (user.totalWorkouts) ? [NSString stringWithFormat:@"%.2f", user.totalExercises/(float)user.totalWorkouts] : @"N/A";
    
    return stats;
}

- (NSArray<NSString *> *)statForIndex:(int)index {
    return @[self.statTitles[index], self.statDetails[index]];
}

- (NSInteger)numStats {
    return self.statTitles.count;
}

#pragma mark - helper methods

- (NSInteger)maxWorkoutDuration {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO]];
    NSArray <BTWorkout *> *arr = [self.context executeFetchRequest:fetchRequest error:nil];
    return (arr && arr.count > 0) ? arr.firstObject.duration : 0;
}

- (NSInteger)maxWorkoutVolume {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:NO]];
    NSArray <BTWorkout *> *arr = [self.context executeFetchRequest:fetchRequest error:nil];
    return (arr && arr.count > 0) ? arr.firstObject.volume : 0;
}

@end
