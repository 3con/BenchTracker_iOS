//
//  BTWorkout+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "AppDelegate.h"
#import "MJExtension.h"
#import "BTWorkoutQRModel.h"
#import "BTTemplateWorkoutQRModel.h"
#import "BT1RMCalculator.h"
#import "BTUser+CoreDataClass.h"
#import <CoreML/CoreML.h>
#import "BTWorkoutClassification.h"

@implementation BTWorkout

+ (BTWorkout *)workout {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:context];
    workout.uuid = [[NSUUID UUID] UUIDString];
    int h = (int)[[[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:[NSDate date]] hour];
    //                       11p - 4:59am = Dusk       5am - 10:59am = M      11am - 1:59pm = MD       2pm - 6:59pm = A     7pm-10:59pm = E
    NSString *timeStr = (h > 22 || h < 5 ) ? @"Dusk" : (h < 11) ? @"Morning" : (h < 13) ? @"Mid-Day" : (h < 19) ? @"Afternoon" : @"Evening";
    workout.name = [NSString stringWithFormat:@"%@ Workout",timeStr];
    workout.date = [NSDate date];
    workout.duration = 0;
    workout.volume = 0;
    workout.numExercises = 0;
    workout.numSets = 0;
    workout.summary = @"0";
    workout.factoredIntoTotals = NO;
    workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    workout.exercises = [[NSOrderedSet alloc] init];
    return workout;
}

+ (NSString *)jsonForWorkout:(BTWorkout *)workout {
    [BTWorkoutQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTExerciseQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTWorkoutQRModel *workoutModel = [[BTWorkoutQRModel alloc] init];
    workoutModel.uuid = workout.uuid;
    workoutModel.name = workout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workoutModel.date = [dateFormatter stringFromDate:workout.date];
    workoutModel.duration = [NSNumber numberWithInteger:(int)workout.duration];
    workoutModel.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        BTExerciseQRModel *exerciseModel = [[BTExerciseQRModel alloc] init];
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
    [BTTemplateWorkoutQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTTemplateExerciseQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s" }; }];
    BTTemplateWorkoutQRModel *workoutModel = [[BTTemplateWorkoutQRModel alloc] init];
    workoutModel.name = workout.name;
    workoutModel.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        BTTemplateExerciseQRModel *exerciseModel = [[BTTemplateExerciseQRModel alloc] init];
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
    [BTWorkoutQRModel mj_setupObjectClassInArray:^NSDictionary *{return @{@"exercises" : @"BTExerciseQRModel"};}];
    [BTWorkoutQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTExerciseQRModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTWorkoutQRModel *workoutModel = [BTWorkoutQRModel mj_objectWithKeyValues:jsonString];
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:context];
    workout.uuid = (workoutModel.uuid) ? workoutModel.uuid : [[NSUUID UUID] UUIDString];
    workout.name = workoutModel.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workout.date = (workoutModel.date) ? [dateFormatter dateFromString: workoutModel.date] : [NSDate date];
    workout.duration = (workoutModel.duration) ? workoutModel.duration.integerValue : 0;
    workout.factoredIntoTotals = NO;
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
    for (BTExerciseQRModel *exerciseModel in workoutModel.exercises) {
        BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:context];
        exercise.name = exerciseModel.name;
        exercise.iteration = exerciseModel.iteration;
        exercise.category = exerciseModel.category;
        exercise.style = exerciseModel.style;
        exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:(exerciseModel.sets) ? exerciseModel.sets : [NSMutableArray array]];
        [exercise calculateOneRM];
        workout.numSets += exercise.numberOfSets;
        workout.volume += exercise.volume;
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

+ (void)resetWorkouts {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTWorkout fetchRequest];
    request.fetchLimit = UINT32_MAX;
    for (BTWorkout *workout in [context executeFetchRequest:request error:nil])
        [context deleteObject:workout];
    [context save:nil];
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

+ (NSInteger)numberOfWorkouts {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 0;
    fetchRequest.fetchBatchSize = 0;
    return [context executeFetchRequest:fetchRequest error:nil].count;
}

+ (NSArray <BTWorkout *> *)allWorkoutsWithFactoredIntoTotalsFilter:(BOOL)factoredIntoTotalsFilter {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 9999;
    fetchRequest.fetchBatchSize = 9999;
    if (factoredIntoTotalsFilter) fetchRequest.predicate = [NSPredicate predicateWithFormat:@"factoredIntoTotals == NO"];
    else                          fetchRequest.predicate = nil;
    return [context executeFetchRequest:fetchRequest error:nil];
}

- (BTWorkoutRank)rankForProperty:(WorkoutPropertyType)property timeSpan:(WorkoutTimeSpanType)timeSpan {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    if (timeSpan == WorkoutTimeSpanType30Day)
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"date >= %@", [NSDate.date dateByAddingTimeInterval:-30*86400]];
    NSSortDescriptor *sD;
    switch (property) {
        case WorkoutPropertyTypeNumSets:  sD = [NSSortDescriptor sortDescriptorWithKey:@"numSets" ascending:NO]; break;
        case WorkoutPropertyTypeVolume:   sD = [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:NO]; break;
        case WorkoutPropertyTypeDuration: sD = [NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO]; break;
    }
    fetchRequest.sortDescriptors = @[sD, [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    fetchRequest.fetchLimit = 30;
    NSArray <BTWorkout *> *results = [context executeFetchRequest:fetchRequest error:nil];
    NSInteger rank = [results indexOfObject:self]+1;
    if (rank < 0) rank = -1;
    NSInteger numTied = 0;
    if (rank > 0) {
        switch (property) {
            case WorkoutPropertyTypeNumSets:
                while ((rank+numTied) < results.count) {
                    if (results[(rank+numTied)].numSets == self.numSets) numTied ++;
                    else break;
                } break;
            case WorkoutPropertyTypeVolume:
                while ((rank+numTied) < results.count) {
                    if (results[(rank+numTied)].volume == self.volume) numTied ++;
                    else break;
                } break;
            case WorkoutPropertyTypeDuration:
                while ((rank+numTied) < results.count) {
                    if (results[(rank+numTied)].duration == self.duration) numTied ++;
                    else break;
                } break;
        }
    }
    BTWorkoutRank rankStruct = { .rank = rank,
                                 .total = results.count,
                                 .numTied = numTied      };
    return rankStruct;
}

- (NSString *)smartNickname {
    return BTSettings.sharedInstance.smartNicknameDict[self.smartName];
}

+ (void)calculateAllSmartNames {
    if (@available(iOS 11, *)) {
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
        fetchRequest.fetchLimit = 9999;
        fetchRequest.fetchBatchSize = 9999;
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"smartName == nil"];
        NSArray *arr = [context executeFetchRequest:fetchRequest error:nil];
        if (!arr.count) return;
        BTWorkoutClassification *model = [[BTWorkoutClassification alloc] init];
        for (BTWorkout *w in arr) {
            if (w.exercises.count > 0)
                [w calculateSmartNameWithModel:model];
        }
        [context save:nil];
    }
}

- (void)calculateSmartName {
    if (@available(iOS 11, *)) {
        if (self.exercises.count > 0) {
            BTWorkoutClassification *model = [[BTWorkoutClassification alloc] init];
            [self calculateSmartNameWithModel:model];
        }
        else self.smartName = nil;
    }
}

- (void)calculateSmartNameWithModel:(id)model {
    if (@available(iOS 11, *)) {
        NSError *error;
        MLMultiArray *arr = [[MLMultiArray alloc] initWithShape:@[@9] dataType:MLMultiArrayDataTypeDouble error:&error];
        NSArray <NSNumber *> *summaryArr = [self summaryArray];
        for (int i = 0; i < summaryArr.count; i++)
            arr[i] = summaryArr[i];
        if (error) NSLog(@"%@", error);
        BTWorkoutClassificationOutput *output = [model predictionFromWorkoutSummary:arr error:&error];
        if (error) NSLog(@"%@", error);
        //NSLog(@"%@   -->   %@   (%.1f)", self.summary, output.classification, output.probabilities[output.classification].floatValue*100);
        self.smartName = output.classification;
    }
}

- (NSArray<NSNumber *> *)summaryArray {
    NSArray *BODY_SPLITS = @[@"Abs / Core", @"Back", @"Biceps", @"Cardio", @"Chest", @"Legs", @"Olympic", @"Shoulders", @"Triceps"];
    NSMutableArray<NSNumber *> *arr = @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0].mutableCopy;
    for (NSString *bodySplit in [self.summary componentsSeparatedByString:@"#"]) {
        NSArray<NSString *> *data = [bodySplit componentsSeparatedByString:@" "];
        if (data.count == 1) continue;
        arr[[BODY_SPLITS indexOfObject:[bodySplit substringFromIndex:data[0].length+1]]] = [NSNumber numberWithInt:data[0].intValue];
    }
    return arr;
}

@end
