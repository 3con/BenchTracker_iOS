//
//  BTUser+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "AppDelegate.h"

@implementation BTUser

- (void)setImage:(UIImage *)image {
    self.imageData = UIImagePNGRepresentation(image);
}

- (UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

- (NSInteger)level { //=X/(10+X/200)+1
    return [BTUser levelForXP:self.xp];
}

- (CGFloat)levelProgress {
    NSInteger currentLevel = self.level;
    if (currentLevel == 1) return self.xp/5.0;
    NSInteger lastLevelXP = 0;
    int xp = self.xp;
    while (!lastLevelXP) {
        if (currentLevel == [BTUser levelForXP:xp]) xp --;
        else lastLevelXP = xp;
    }
    NSInteger nextLevelXP = 0;
    xp = self.xp;
    while (!nextLevelXP) {
        if (currentLevel == [BTUser levelForXP:xp]) xp ++;
        else nextLevelXP = xp;
    }
    return (self.xp-lastLevelXP)/(float)(nextLevelXP-lastLevelXP);
}

+ (BTUser *)sharedInstance {
    static BTUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self fetchUser];
    });
    return sharedInstance;
}

+ (void)removeWorkoutFromTotals:(BTWorkout *)workout {
    if (workout.factoredIntoTotals) {
        workout.factoredIntoTotals = NO;
        BTUser *user = [BTUser sharedInstance];
        user.totalDuration -= workout.duration;
        user.totalVolume -= workout.volume;
        user.totalWorkouts -= 1;
    }
}

+ (void)addWorkoutToTotals:(BTWorkout *)workout {
    if (!workout.factoredIntoTotals) {
        workout.factoredIntoTotals = YES;
        BTUser *user = [BTUser sharedInstance];
        user.totalDuration += workout.duration;
        user.totalVolume += workout.volume;
        user.totalWorkouts += 1;
    }
    else NSLog(@"BTUser totals error: this probably shouldn't happen!");
}

+ (void)checkForTotalsPurge {
    [self runPurgeNumber:0];
}

+ (void)runPurgeNumber:(int)num {
    BTUser *user = [BTUser sharedInstance];
    NSInteger numWorkouts = [BTWorkout numberOfWorkouts];
    if (user.totalWorkouts == numWorkouts) return;
    if (user.totalWorkouts > numWorkouts) [BTUser totalPurge];
    if (num > 5) [BTUser totalPurge];
    NSLog(@"Running short pruge");
    for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:YES])
        [BTUser addWorkoutToTotals:workout];
    [self runPurgeNumber:num+1];
}

+ (void)totalPurge {
    NSLog(@"Running total (long) purge");
    NSLog(@"BTUser totals error: this probably shouldn't happen!");
    for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:NO]) {
        workout.factoredIntoTotals = NO;
        [BTUser addWorkoutToTotals:workout];
    }
}

+ (void)updateStreaks {
    BTUser *user = [BTUser sharedInstance];
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                 fromDate:NSDate.date];
    NSDateComponents *components2 = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                  fromDate:[NSDate.date dateByAddingTimeInterval:-86400]];
    NSDate *today = [NSCalendar.currentCalendar dateFromComponents:components];
    NSDate *yesterday = [NSCalendar.currentCalendar dateFromComponents:components2];
    NSInteger count = 0;
    if ([BTWorkout workoutsBetweenBeginDate:today andEndDate:[today dateByAddingTimeInterval:86400]].count > 0) count = 1;
    if ([BTWorkout workoutsBetweenBeginDate:yesterday andEndDate:[yesterday dateByAddingTimeInterval:86400]].count > 0) count ++;
    else if (!count) {
        user.currentStreak = 0;
        return;
    }
    if (count) {
        int i = 2;
        while (YES) {
            NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                         fromDate:[NSDate.date dateByAddingTimeInterval:-86400*i]];
            NSDate *nDate = [NSCalendar.currentCalendar dateFromComponents:components];
            if ([BTWorkout workoutsBetweenBeginDate:nDate andEndDate:[nDate dateByAddingTimeInterval:86400]].count > 0) count ++;
            else break;
            i++;
        }
    }
    user.currentStreak = count;
    user.longestStreak = MAX(user.currentStreak, user.longestStreak);
}

#pragma mark - private methods

+ (BTUser *)fetchUser {
    NSFetchRequest *request = [BTUser fetchRequest];
    request.fetchLimit = 1;
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error || object.count == 0) {
        NSLog(@"BTUser coreData error or creation: %@",error);
        BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:context];
        user.dateCreated = [NSDate date];
        user.name = nil;
        user.imageData = nil;
        user.weight = 0;
        user.achievementListVersion = 0;
        user.xp = 0;
        user.currentStreak = 0;
        user.longestStreak = 0;
        user.totalDuration = 0;
        user.totalVolume = 0;
        user.totalWorkouts = 0;
        [context save:nil];
        return user;
    }
    return object[0];
}

+ (NSInteger)levelForXP:(NSInteger)xp {
    return xp/(10+xp/200)+1;
}

@end
