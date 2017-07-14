//
//  BTRecentWorkoutsManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTRecentWorkoutsManager.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "AppDelegate.h"

@interface BTRecentWorkoutsManager ()

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) NSMutableArray <BTWorkout *> *recentWorkouts;
@property (nonatomic) NSMutableArray <NSString *> *workoutNamesCache;
@property (nonatomic) NSMutableArray <NSString *> *workoutShortDatesCache;
@property (nonatomic) NSMutableArray <NSString *> *workoutDatesCache;

@property (nonatomic) NSDate *firstDayOfWeek;

@end

@implementation BTRecentWorkoutsManager

- (id)init {
    if (self = [super init]) {
        self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        self.settings = [BTSettings sharedInstance];
        NSDate *today = [self normalizedDateForDate:[NSDate date]];
        NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:today];
        NSInteger offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
        self.firstDayOfWeek = [today dateByAddingTimeInterval:offset*86400];
    }
    return self;
}

- (NSDate *)normalizedDateForDate:(NSDate *)date {
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                 fromDate:date];
    return [NSCalendar.currentCalendar dateFromComponents:components];
}

- (void)reloadData {
    self.workoutDatesCache = nil;
    [self performFetch];
}

- (NSInteger)numberOfRecentWorkouts {
    return (self.recentWorkouts) ? self.recentWorkouts.count : 0;
}

- (NSArray <NSString *> *)workoutNames {
    if (!self.recentWorkouts) [self performFetch];
    if (self.workoutNamesCache) return self.workoutNamesCache;
    self.workoutNamesCache = [NSMutableArray array];
    for (BTWorkout *workout in self.recentWorkouts)
        [self.workoutNamesCache addObject:workout.name];
    return self.workoutNamesCache;
}

- (NSArray <NSString *> *)workoutShortDates {
    if (!self.recentWorkouts) [self performFetch];
    if (self.workoutShortDatesCache) return self.workoutShortDatesCache;
    self.workoutShortDatesCache = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMMM d";
    for (BTWorkout *workout in self.recentWorkouts)
        [self.workoutShortDatesCache addObject:[formatter stringFromDate:workout.date]];
    return self.workoutShortDatesCache;
}

- (NSArray <NSString *> *)workoutDates {
    if (!self.recentWorkouts) [self performFetch];
    if (self.workoutDatesCache) return self.workoutDatesCache;
    self.workoutDatesCache = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E, MMMM d";
    for (BTWorkout *workout in self.recentWorkouts)
        [self.workoutDatesCache addObject:[formatter stringFromDate:workout.date]];
    return self.workoutDatesCache;
}

- (NSDictionary *)workoutExercises {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableDictionary <NSString *, NSNumber *> *exercises = [NSMutableDictionary dictionary];
    for (BTWorkout *workout in self.recentWorkouts) {
        for (BTExercise *exercise in workout.exercises) {
            if (!exercises[exercise.name]) exercises[exercise.name] = [NSNumber numberWithInt:1];
            else exercises[exercise.name] = [NSNumber numberWithInt:exercises[exercise.name].intValue+1];
        }
    }
    return exercises;
}

- (NSString *)formattedFirstDayOfWeek {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM d";
    return [formatter stringFromDate:self.firstDayOfWeek];
}

- (NSDictionary *)workoutExerciseTypesThisWeek {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableDictionary <NSString *, NSNumber *> *exerciseTypes = [NSMutableDictionary dictionary];
    for (BTWorkout *workout in self.recentWorkouts) {
        if ([workout.date compare:self.firstDayOfWeek] != NSOrderedAscending) {
            for (NSString *exerciseType in [workout.summary componentsSeparatedByString:@"#"]) {
                if (exerciseType.length < 2) break;
                NSArray <NSString *> *splt = [exerciseType componentsSeparatedByString:@" "];
                NSString *name = [exerciseType substringFromIndex:splt[0].length+1];
                if (!exerciseTypes[name]) exerciseTypes[name] = [NSNumber numberWithInt:splt[0].intValue];
                else exerciseTypes[name] = [NSNumber numberWithInt:exerciseTypes[name].intValue+splt[0].intValue];
            }
        }
    }
    return exerciseTypes;
}

- (NSArray <NSString *> *)otherDataThisWeek {
    if (!self.recentWorkouts) [self performFetch];
    int workouts = 0, exercises = 0, sets = 0, volume = 0;
    for (BTWorkout *workout in self.recentWorkouts) {
        if ([workout.date compare:self.firstDayOfWeek] != NSOrderedAscending) {
            workouts ++;
            exercises += workout.numExercises;
            sets += workout.numSets;
            volume += workout.volume;
        }
    }
    return @[[NSString stringWithFormat:@"%d",workouts], [NSString stringWithFormat:@"%d", exercises],
             [NSString stringWithFormat:@"%d",sets], [NSString stringWithFormat:@"%dk %@", volume/1000, self.settings.weightSuffix]];
}

- (NSArray <NSNumber *> *)workoutVolumes {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableArray *volumes = [NSMutableArray array];
    for (BTWorkout *workout in self.recentWorkouts)
        [volumes addObject:[NSNumber numberWithFloat:workout.volume/1000]];
    return volumes;
}

- (NSArray <NSNumber *> *)workoutDurations {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableArray *durations = [NSMutableArray array];
    for (BTWorkout *workout in self.recentWorkouts)
        [durations addObject:[NSNumber numberWithFloat:workout.duration/60]];
    return durations;
}

- (NSArray <NSNumber *> *)workoutNumExercises {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableArray *numExercises = [NSMutableArray array];
    for (BTWorkout *workout in self.recentWorkouts)
        [numExercises addObject:[NSNumber numberWithFloat:workout.numExercises]];
    return numExercises;
}

- (NSArray <NSNumber *> *)workoutNumSets {
    if (!self.recentWorkouts) [self performFetch];
    NSMutableArray *numSets = [NSMutableArray array];
    for (BTWorkout *workout in self.recentWorkouts)
        [numSets addObject:[NSNumber numberWithFloat:workout.numSets]];
    return numSets;
}

#pragma mark - private methods

- (void)performFetch {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    request.fetchLimit = self.maxFetch;
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    request.sortDescriptors = @[descriptor];
    NSError *error;
    self.recentWorkouts = [NSMutableArray arrayWithArray:[self.context executeFetchRequest:request error:&error]];
    if (error) NSLog(@"Recent workouts manager fetch error: %@",error);
}

@end
