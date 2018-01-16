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
    
    stats.statTitles[0] = @"Tracking for";
    NSInteger days = [[NSDate date] timeIntervalSinceDate:user.dateCreated]/86400+1;
    stats.statDetails[0] = [NSString stringWithFormat:@"%ld day%@", days, (days == 1) ? @"" : @"s"];
    
    stats.statTitles[1] = @"Total Duration";
    stats.statDetails[1] = (user.totalDuration < 100*3600.0) ? [NSString stringWithFormat:@"%.1f hrs", user.totalDuration/3600.0]:
                                                               [NSString stringWithFormat:@"%.0f hrs", user.totalDuration/3600.0];
    
    stats.statTitles[2] = @"# of Workouts";
    stats.statDetails[2] = [NSString stringWithFormat:@"%lld", user.totalWorkouts];
    
    stats.statTitles[3] = @"Total Volume";
    stats.statDetails[3] = (user.totalVolume < 1000000) ? [NSString stringWithFormat:@"%lldk %@", user.totalVolume/1000, settings.weightSuffix] :
                                                          [NSString stringWithFormat:@"%.2fm %@", user.totalVolume/1000000.0, settings.weightSuffix];
    
    stats.statTitles[4] = @"Current Streak";
    stats.statDetails[4] = [NSString stringWithFormat:@"%lld day%@", user.currentStreak, (user.currentStreak == 1) ? @"" : @"s"];
    
    stats.statTitles[5] = @"Longest Streak";
    stats.statDetails[5] = [NSString stringWithFormat:@"%lld day%@", user.longestStreak, (user.longestStreak == 1) ? @"" : @"s"];
    
    stats.statTitles[6] = @"Workout %";
    stats.statDetails[6] = [NSString stringWithFormat:@"%.0f%%",
        ((float)user.totalWorkouts)/([[NSDate date] timeIntervalSinceDate:user.dateCreated]/86400+1)*100];
    
    stats.statTitles[7] = @"Volume / Hour";
    stats.statDetails[7] = (user.totalDuration) ?
    [NSString stringWithFormat:@"%.1fk %@", user.totalVolume/1000.0/user.totalDuration*3600, settings.weightSuffix] :
    @"N/A";
    
    stats.statTitles[8] = @"Average Duration";
    stats.statDetails[8] = (user.totalWorkouts) ?
    [NSString stringWithFormat:@"%.1f min", user.totalDuration/60.0/user.totalWorkouts] :
    @"N/A";

    stats.statTitles[9] = @"Average Volume";
    stats.statDetails[9] = (user.totalWorkouts) ?
        [NSString stringWithFormat:@"%.1fk %@", user.totalVolume/1000.0/user.totalWorkouts, settings.weightSuffix] : @"N/A";
    
    stats.statTitles[10] = @"Longest Duration";
    stats.statDetails[10] = [NSString stringWithFormat:@"%ld min", [stats maxWorkoutDuration]/60];
    
    stats.statTitles[11] = @"Highest Volume";
    stats.statDetails[11] = [NSString stringWithFormat:@"%ldk %@",[stats maxWorkoutVolume]/1000, settings.weightSuffix];
    
    return stats;
}

- (NSArray<NSString *> *)statForIndex:(int)index {
    return @[self.statTitles[index], self.statDetails[index]];
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
