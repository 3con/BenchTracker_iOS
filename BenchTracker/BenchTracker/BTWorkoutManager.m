//
//  BTWorkoutManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkoutManager.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTAWSWorkout.h"
#import "AppDelegate.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "BenchTrackerKeys.h"
#import "ExerciseModel.h"
#import "BTUserManager.h"
#import "MJExtension.h"
#import "BTJSONWorkout.h"

@interface BTWorkoutManager ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *mapper;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) BTUserManager *userManager;

@end

@implementation BTWorkoutManager

+ (id)sharedInstance {
    static BTWorkoutManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        sharedInstance.mapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    });
    return sharedInstance;
}

#pragma mark - client only

- (NSString *)jsonForWorkout:(BTWorkout *)workout {
    [BTJSONWorkout mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"summary" : @"s",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTJSONExercise mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"date" : @"d",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTJSONWorkout *workoutModel = [[BTJSONWorkout alloc] init];
    workoutModel.uuid = workout.uuid;
    workoutModel.name = workout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workoutModel.date = [dateFormatter stringFromDate:workout.date];
    workoutModel.duration = [NSNumber numberWithInteger:workout.duration];
    workoutModel.summary = workout.summary;
    workoutModel.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        BTJSONExercise *exerciseModel = [[BTJSONExercise alloc] init];
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
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%ld",jsonString.length);
    [self createWorkoutWithJSON:jsonString];
    return [NSString stringWithFormat:@"%@",jsonString];
}

- (BTWorkout *)createWorkoutWithJSON:(NSString *)jsonString {
    [BTJSONWorkout mj_setupObjectClassInArray:^NSDictionary *{return @{@"exercises" : @"BTJSONExercise"};}];
    [BTJSONWorkout mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"uuid" : @"u",
                 @"name" : @"n",
                 @"date" : @"d",
                 @"duration" : @"t",
                 @"summary" : @"s",
                 @"supersets" : @"z",
                 @"exercises" : @"e", }; }];
    [BTJSONExercise mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"name" : @"n",
                 @"iteration" : @"i",
                 @"date" : @"d",
                 @"category" : @"c",
                 @"style" : @"s",
                 @"sets" : @"x" }; }];
    BTJSONWorkout *workoutModel = [BTJSONWorkout mj_objectWithKeyValues:jsonString];
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:self.context];
    workout.uuid = workoutModel.uuid;
    workout.name = workoutModel.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workout.date = [dateFormatter dateFromString:workoutModel.date];
    workout.duration = workoutModel.duration.integerValue;
    workout.summary = workoutModel.summary;
    NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets = [NSMutableArray array];
    for (NSString *string in workoutModel.supersets) {
        NSMutableArray *numArr = [NSMutableArray array];
        for (NSString *s in [string componentsSeparatedByString:@" "])
            [numArr addObject:[NSNumber numberWithInt:s.intValue]];
        [tempSupersets addObject:numArr];
    }
    workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:tempSupersets];
    workout.exercises = [[NSOrderedSet alloc] init];
    for (BTJSONExercise *exerciseModel in workoutModel.exercises) {
        BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:self.context];
        exercise.name = exerciseModel.name;
        exercise.iteration = exerciseModel.iteration;
        exercise.category = exerciseModel.category;
        exercise.style = exerciseModel.style;
        exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:exerciseModel.sets];
        exercise.workout = workout;
        [workout addExercisesObject:exercise];
    }
    [self saveCoreData];
    return workout;
}

#pragma mark - client -> server

- (BTWorkout *)createWorkout {
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:self.context];
    workout.uuid = [[NSUUID UUID] UUIDString];
    int h = (int)[[[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:[NSDate date]] hour];
    NSString *timeStr = (h > 22 || h < 4 ) ? @"Dusk" : (h < 11) ? @"Morning" : (h < 13) ? @"Mid Day" : (h < 19) ? @"Afternoon" : @"Evening";
    workout.name = [NSString stringWithFormat:@"%@ Workout",timeStr];
    workout.date = [NSDate date];
    workout.duration = 0;
    workout.summary = @"0";
    workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    workout.exercises = [[NSOrderedSet alloc] init];
    BTAWSWorkout *awsWorkout = [self awsWorkoutForWorkout:workout];
    [self pushAWSWorkout:awsWorkout withCompletionBlock:^{
        
    }];
    [self.delegate workoutManager:self didCreateWorkout:workout]; //add to recentEdits list, send new user
    return workout;
}

- (void)saveEditedWorkout:(BTWorkout *)workout {
    BTAWSWorkout *awsWorkout = [self awsWorkoutForWorkout:workout];
    [self pushAWSWorkout:awsWorkout withCompletionBlock:^{
        
    }];
    [self.delegate workoutManager:self didEditWorkout:workout]; //add to recentEdits list, send new user
}

- (void)deleteWorkout:(BTWorkout *)workout {
    BTAWSWorkout *awsWorkout = [BTAWSWorkout new];
    awsWorkout.uuid = workout.uuid;
    [[self.mapper remove:awsWorkout] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"workoutManager error: %@",task.error);
        return nil;
    }];
    [self.delegate workoutManager:self didDeleteWorkout:workout]; //add to recentEdits list, send new user
}

#pragma mark - server -> client

- (void)fetchWorkoutFromAWSWithUUID:(NSString *)uuid completionBlock:(void (^)(BTWorkout *workout))completed {
    [[self.mapper load:[BTAWSWorkout class] hashKey:uuid rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"The request failed. Error: [%@]", task.error);
        else {
            if (task.result) { //workout exists
                BTAWSWorkout *awsWorkout = task.result;
                completed([self workoutForAWSWorkout:awsWorkout]);
            }
            else NSLog(@"AWS workout not found");
            completed(nil);
        }
        return nil;
    }];
}

- (void)updateWorkoutsWithLocalRecentEdits: (NSMutableArray<NSString *>*)localRecentEdits AWSRecentEdits: (NSMutableArray<NSString *>*)awsRecentEdits {
    if (![awsRecentEdits.firstObject isEqualToString:AWS_EMPTY]) {
        NSMutableSet *deleteList = [NSMutableSet set];
        NSMutableSet *downloadList = [NSMutableSet set];
        //go through array to identify all changes until point of sync
        NSString *mostRecentLocalEdit = localRecentEdits.lastObject;
        for (NSInteger i = awsRecentEdits.count-1; i >= 0; i--) {
            if ([mostRecentLocalEdit isEqualToString:awsRecentEdits[i]]) break;
            NSArray <NSString *> *edit = [awsRecentEdits[i] componentsSeparatedByString:@" "];
            if ([edit[1] isEqualToString:@"A"]) [downloadList addObject:edit[2]];
            else if ([edit[1] isEqualToString:@"E"]) {
                [deleteList addObject:edit[2]];
                [downloadList addObject:edit[2]];
            }
            else {
                [deleteList addObject:edit[2]];
                [downloadList removeObject:edit[2]];
            }
        }
        //trim out irrelevent changes?
        //go through each change:
        //   D: delete from CD
        //   E: delete from CD, download, convert, add
        //   A: download, convert, add
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
        request.fetchLimit = 1;
        NSError *error;
        for (NSString *uuid in deleteList) {
            request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid = '%@'",uuid]];
            BTWorkout *workout = [self.context executeFetchRequest:request error:&error].firstObject;
            if (error) NSLog(@"workoutManager update fetch error: %@",error);
            if (workout) [self.context deleteObject:workout];
        }
        self.userManager = [BTUserManager sharedInstance];
        for (NSString *uuid in downloadList) {
            [self fetchWorkoutFromAWSWithUUID:uuid completionBlock:^(BTWorkout *workout) {
                if (workout) [self.userManager addWorkoutToLocalUser:workout];
            }];
        }
        //save to CoreData
        [self saveCoreData];
        //checksum to make sure CD and user workout list are same length
        //     ---> not same: hard compare DBs
    }
}

#pragma mark - client helpers

- (NSArray <BTWorkout *> *)workoutsBetweenBeginDate:(NSDate *)d1 andEndDate:(NSDate *)d2 {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    NSMutableArray *predicates = [[NSMutableArray alloc] init];
    NSPredicate *subPredFrom = [NSPredicate predicateWithFormat:@"date >= %@ ", d1];
    [predicates addObject:subPredFrom];
    NSPredicate *subPredTo = [NSPredicate predicateWithFormat:@"date < %@", d2];
    [predicates addObject:subPredTo];
    [fetchRequest setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:predicates]];
    return (NSArray <BTWorkout *> *)[self.context executeFetchRequest:fetchRequest error:nil];
}

#pragma mark - private methods

- (BTAWSWorkout *)awsWorkoutForWorkout: (BTWorkout *)workout {
    BTAWSWorkout *awsWorkout = [BTAWSWorkout new];
    awsWorkout.uuid = workout.uuid;
    awsWorkout.name = workout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    awsWorkout.date = [dateFormatter stringFromDate:workout.date];
    awsWorkout.duration = [NSNumber numberWithInteger:workout.duration];
    awsWorkout.summary = workout.summary;
    awsWorkout.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises)
        [awsWorkout.exercises addObject:[self jsonExerciseforExercise:exercise]];
    if (awsWorkout.exercises.count == 0) [awsWorkout.exercises addObject:AWS_EMPTY];
    awsWorkout.supersets = [[NSMutableArray alloc] init];
    for (NSMutableArray <NSNumber *> *superset in [NSKeyedUnarchiver unarchiveObjectWithData:workout.supersets]) {
        NSString *s = @"";
        for (NSNumber *num in superset) s = [NSString stringWithFormat:@"%@ %d", s, num.intValue];
        [awsWorkout.supersets addObject:[s substringFromIndex:1]];
    }
    if (awsWorkout.supersets.count == 0) [awsWorkout.supersets addObject:AWS_EMPTY];
    return awsWorkout;
}

- (BTWorkout *)workoutForAWSWorkout: (BTAWSWorkout *)awsWorkout { //doesnt add to recentEdits
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:self.context];
    workout.uuid = awsWorkout.uuid;
    workout.name = awsWorkout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    workout.date = [dateFormatter dateFromString:awsWorkout.date];
    workout.duration = awsWorkout.duration.integerValue;
    workout.summary = awsWorkout.summary;
    if ([awsWorkout.supersets.firstObject isEqualToString:AWS_EMPTY])
         workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    else {
        NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets = [NSMutableArray array];
        for (NSString *string in awsWorkout.supersets) {
            NSMutableArray *numArr = [NSMutableArray array];
            for (NSString *s in [string componentsSeparatedByString:@" "])
                [numArr addObject:[NSNumber numberWithInt:s.intValue]];
            [tempSupersets addObject:numArr];
        }
        workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:tempSupersets];
    }
    workout.exercises = [[NSOrderedSet alloc] init];
    if (![awsWorkout.exercises.firstObject isEqualToString:AWS_EMPTY]) {
        for (NSString *jsonExercise in awsWorkout.exercises) {
            BTExercise *exercise = [self exerciseForJSONExercise:jsonExercise];
            exercise.workout = workout;
            [workout addExercisesObject:exercise];
        }
    }
    [self saveCoreData];
    return workout;
}

- (NSString *)jsonExerciseforExercise:(BTExercise *)exercise {
    NSString *r = @"{";
    r = [NSString stringWithFormat:@"%@\"style\":\"%@\",",r, exercise.style];
    r = [NSString stringWithFormat:@"%@\"name\":\"%@\",",r, exercise.name];
    r = [NSString stringWithFormat:@"%@\"iteration\":\"%@\",",r, (exercise.iteration) ? AWS_EMPTY : exercise.iteration];
    r = [NSString stringWithFormat:@"%@\"category\":\"%@\",",r, exercise.category];
    r = [NSString stringWithFormat:@"%@\"sets\":%@",r, [self stringForSetsData: exercise.sets]];
    return [NSString stringWithFormat:@"%@}",r];
}

- (BTExercise *)exerciseForJSONExercise:(NSString *)jsonExercise {
    NSError *error;
    ExerciseModel *model = [[ExerciseModel alloc] initWithString:jsonExercise error:&error];
    if(error) NSLog(@"workoutManager JSON model error:%@",error);
    BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:self.context];
    exercise.name = model.name;
    exercise.iteration = ([model.iteration isEqualToString:AWS_EMPTY]) ? nil : model.iteration;
    exercise.category = model.category;
    exercise.style = model.style;
    if ([model.sets.firstObject isEqualToString:AWS_EMPTY])
         exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    else exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:model.sets];
    return exercise;
}

- (NSString *)stringForSetsData:(NSData *)data {
    if (!data) return [NSString stringWithFormat:@"[ \"%@\" ]",AWS_EMPTY];
    NSArray <NSString *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (arr.count == 0) return [NSString stringWithFormat:@"[ \"%@\" ]",AWS_EMPTY];
    NSString *r = @"";
    for (NSString *s in arr) r = [NSString stringWithFormat:@"%@,\"%@\"",r,s];
    return [NSString stringWithFormat:@"[ %@ ]",[r substringFromIndex:1]];
}

- (void)pushAWSWorkout:(BTAWSWorkout *)awsWorkout withCompletionBlock:(void (^)())completed {
    [[self.mapper save:awsWorkout] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"workoutManager push error: [%@]", task.error);
        else completed();
        return nil;
    }];
}

- (void)saveCoreData {
    NSError *error;
    [self.context save:&error];
    if(error) NSLog(@"workoutManager error: %@",error);
}

@end
