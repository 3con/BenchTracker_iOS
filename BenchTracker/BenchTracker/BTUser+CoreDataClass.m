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
    BTUser *user = [BTUser sharedInstance];
    NSInteger numWorkouts = [BTWorkout numberOfWorkouts];
    if (numWorkouts < user.totalWorkouts) {
        NSLog(@"Purging (long workouts)");
        NSLog(@"BTUser totals error: this probably shouldn't happen!");
        for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:NO]) {
            workout.factoredIntoTotals = NO;
            [BTUser addWorkoutToTotals:workout];
        }
    }
    else if (numWorkouts > user.totalWorkouts) {
        NSLog(@"Purging (short workouts)");
        for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:YES])
            [BTUser addWorkoutToTotals:workout];
        [self checkForTotalsPurge];
    }
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


@end
