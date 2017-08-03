//
//  BTWorkout+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "AppDelegate.h"
#import "MJExtension.h"
#import "BTWorkoutModel.h"
#import "BTTemplateWorkoutModel.h"
#import "BT1RMCalculator.h"

#import "BTUser+CoreDataClass.h"

@implementation BTWorkout

+ (BTWorkout *)workout {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:context];
    workout.uuid = [[NSUUID UUID] UUIDString];
    int h = (int)[[[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:[NSDate date]] hour];
    NSString *timeStr = (h > 22 || h < 4 ) ? @"Dusk" : (h < 11) ? @"Morning" : (h < 13) ? @"Mid Day" : (h < 19) ? @"Afternoon" : @"Evening";
    workout.name = [NSString stringWithFormat:@"%@ Workout",timeStr];
    workout.date = [NSDate date];
    workout.duration = 0;
    workout.volume = 0;
    workout.numExercises = 0;
    workout.numSets = 0;
    workout.summary = @"0";
    workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    workout.exercises = [[NSOrderedSet alloc] init];
    return workout;
}

+ (NSString *)jsonForWorkout:(BTWorkout *)workout {
    [BTWorkoutModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTExerciseModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTWorkoutModel *workoutModel = [[BTWorkoutModel alloc] init];
    workoutModel.uuid = workout.uuid;
    workoutModel.name = workout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workoutModel.date = [dateFormatter stringFromDate:workout.date];
    workoutModel.duration = [NSNumber numberWithInteger:workout.duration];
    workoutModel.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        BTExerciseModel *exerciseModel = [[BTExerciseModel alloc] init];
        exerciseModel.name = exercise.name;
        exerciseModel.iteration = exercise.iteration;
        exerciseModel.category = exercise.category;
        exerciseModel.style = exercise.style;
        exerciseModel.sets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
        [workoutModel.exercises addObject:exerciseModel];
    }
    workoutModel.supersets = [[NSMutableArray alloc] init];
    for (NSMutableArray <NSNumber *> *superset in [NSKeyedUnarchiver unarchiveObjectWithData:workout.supersets]) {
        NSString *s = @"";
        for (NSNumber *num in superset) s = [NSString stringWithFormat:@"%@ %d", s, num.intValue];
        [workoutModel.supersets addObject:[s substringFromIndex:1]];
    }
    NSDictionary *json = workoutModel.mj_keyValues;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (error) NSLog(@"Workout Manager dict to string error: %@",error);
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)jsonForTemplateWorkout:(BTWorkout *)workout {
    [BTTemplateWorkoutModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTTemplateExerciseModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s" }; }];
    BTTemplateWorkoutModel *workoutModel = [[BTTemplateWorkoutModel alloc] init];
    workoutModel.name = workout.name;
    workoutModel.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        BTTemplateExerciseModel *exerciseModel = [[BTTemplateExerciseModel alloc] init];
        exerciseModel.name = exercise.name;
        exerciseModel.iteration = exercise.iteration;
        exerciseModel.category = exercise.category;
        exerciseModel.style = exercise.style;
        [workoutModel.exercises addObject:exerciseModel];
    }
    workoutModel.supersets = [[NSMutableArray alloc] init];
    for (NSMutableArray <NSNumber *> *superset in [NSKeyedUnarchiver unarchiveObjectWithData:workout.supersets]) {
        NSString *s = @"";
        for (NSNumber *num in superset) s = [NSString stringWithFormat:@"%@ %d", s, num.intValue];
        [workoutModel.supersets addObject:[s substringFromIndex:1]];
    }
    NSDictionary *json = workoutModel.mj_keyValues;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:&error];
    if (error) NSLog(@"Workout Manager dict to string error: %@",error);
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (BTWorkout *)workoutForJSON:(NSString *)jsonString {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    [BTWorkoutModel mj_setupObjectClassInArray:^NSDictionary *{return @{@"exercises" : @"BTExerciseModel"};}];
    [BTWorkoutModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTExerciseModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTWorkoutModel *workoutModel = [BTWorkoutModel mj_objectWithKeyValues:jsonString];
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:context];
    workout.uuid = (workoutModel.uuid) ? workoutModel.uuid : [[NSUUID UUID] UUIDString];
    workout.name = workoutModel.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workout.date = (workoutModel.date) ? [dateFormatter dateFromString: workoutModel.date] : [NSDate date];
    workout.duration = (workoutModel.duration) ? workoutModel.duration.integerValue : 0;
    workout.summary = @"0";
    NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets = [NSMutableArray array];
    for (NSString *string in workoutModel.supersets) {
        NSMutableArray *numArr = [NSMutableArray array];
        for (NSString *s in [string componentsSeparatedByString:@" "])
            [numArr addObject:[NSNumber numberWithInt:s.intValue]];
        [tempSupersets addObject:numArr];
    }
    workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:tempSupersets];
    workout.exercises = [[NSOrderedSet alloc] init];
    workout.volume = 0;
    workout.numExercises = workoutModel.exercises.count;
    workout.numSets = 0;
    for (BTExerciseModel *exerciseModel in workoutModel.exercises) {
        BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:context];
        exercise.name = exerciseModel.name;
        exercise.iteration = exerciseModel.iteration;
        exercise.category = exerciseModel.category;
        exercise.style = exerciseModel.style;
        workout.numSets += (exerciseModel.sets) ? exerciseModel.sets.count : 0;
        exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:(exerciseModel.sets) ? exerciseModel.sets : [NSMutableArray array]];
        exercise.oneRM = 0;
        if ([exerciseModel.style isEqualToString:STYLE_REPSWEIGHT]) {
            for (NSString *set in exerciseModel.sets) {
                NSArray <NSString *> *split = [set componentsSeparatedByString:@" "];
                workout.volume += split[0].floatValue*split[1].floatValue;
                exercise.oneRM = MAX(exercise.oneRM, [BT1RMCalculator equivilentForReps:split[0].intValue weight:split[1].floatValue]);
            }
        }
        exercise.workout = workout;
        [workout addExercisesObject:exercise];
    }
    NSMutableDictionary <NSString *, NSNumber *> *dict = [[NSMutableDictionary alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        if (dict[exercise.category]) dict[exercise.category] = [NSNumber numberWithInt:dict[exercise.category].intValue + 1];
        else                         dict[exercise.category] = [NSNumber numberWithInt:1];
    }
    workout.summary = @"0";
    if (workout.exercises.count > 0) {
        for (NSString *key in dict.allKeys)
            workout.summary = [NSString stringWithFormat:@"%@#%@ %@",workout.summary, dict[key], key];
        workout.summary = [workout.summary substringFromIndex:2];
    }
    [context save:nil];
    return workout;
}

+ (NSArray <BTWorkout *> *)workoutsBetweenBeginDate:(NSDate *)d1 andEndDate:(NSDate *)d2 {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    NSPredicate *subPredFrom = [NSPredicate predicateWithFormat:@"date >= %@ ", d1];
    [predicates addObject:subPredFrom];
    NSPredicate *subPredTo = [NSPredicate predicateWithFormat:@"date < %@", d2];
    [predicates addObject:subPredTo];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    return (NSArray <BTWorkout *> *)[context executeFetchRequest:fetchRequest error:nil];
}

@end
