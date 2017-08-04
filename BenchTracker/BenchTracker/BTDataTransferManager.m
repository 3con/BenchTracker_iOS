//
//  BTDataTransferManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTDataTransferManager.h"
#import "AppDelegate.h"
#import "BTDataTransferModel.h"
#import "BTUser+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BT1RMCalculator.h"

#define DATA_TRANSFER_VERSION 1

@implementation BTDataTransferManager

+ (NSString *)pathForJSONDataExport {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTDataTransferModel *transferModel = [[BTDataTransferModel alloc] init];
    transferModel.version = DATA_TRANSFER_VERSION;
    //SERIALIZE USER
    BTUserModel *userModel = [[BTUserModel alloc] init];
    userModel.dateCreated = [BTUser sharedInstance].dateCreated;
    transferModel.user = userModel;
    //SERIALIZE SETTINGS
    BTSettingsModel *settingsModel = [[BTSettingsModel alloc] init];
    BTSettings *settings = [BTSettings sharedInstance];
    settingsModel.startWeekOnMonday = settings.startWeekOnMonday;
    settingsModel.disableSleep = settings.disableSleep;
    settingsModel.weightInLbs = settings.weightInLbs;
    transferModel.settings = settingsModel;
    //SERIALIZE TYPELIST
    transferModel.typeList = [BTExerciseType typeListModel];
    //SERIALIZE WORKOUTS
    NSFetchRequest *request = [BTWorkout fetchRequest];
    request.fetchLimit = 0;
    request.fetchBatchSize = 0;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSArray *arr = [context executeFetchRequest:request error:nil];
    transferModel.workouts = (NSMutableArray <BTWorkoutModel *> <BTWorkoutModel> *)[NSMutableArray array];
    for (BTWorkout *workout in arr)
        [transferModel.workouts addObject:[BTDataTransferManager modelForWorkout:workout]];
    //SAVE TO FILE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/BenchTrackerData.btd", paths.firstObject];
    [[transferModel toJSONData] writeToFile:path atomically:YES];
    return path;
}

+ (BOOL)loadJSONDataWithURL:(NSURL *)url {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSError *error;
    NSString *JSONString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    if (error) { NSLog(@"Data Transfer error: %@",error); return NO; }
    BTDataTransferModel *transferModel = [[BTDataTransferModel alloc] initWithString:JSONString error:&error];
    if (error) { NSLog(@"Data Transfer error: %@",error); return NO; }
    //CHECK VERSION
    if (transferModel.version > DATA_TRANSFER_VERSION) return NO;
    //PARSE USER
    [BTUser sharedInstance].dateCreated = transferModel.user.dateCreated;
    //PARSE SETTINGS
    BTSettings *settings = [BTSettings sharedInstance];
    [settings reset];
    settings.startWeekOnMonday = transferModel.settings.startWeekOnMonday;
    settings.weightInLbs = transferModel.settings.weightInLbs;
    settings.disableSleep = transferModel.settings.disableSleep;
    //PARSE TYPELIST
    [BTExerciseType resetTypeList];
    [BTExerciseType loadTypeListModel:transferModel.typeList];
    //PARSE WORKOUTS
    [BTWorkout resetWorkouts];
    for (BTWorkoutModel *workoutModel in transferModel.workouts)
        [BTDataTransferManager workoutForModel:workoutModel];
    [context save:nil];
    return true;
}

#pragma mark - private helper methods

+ (BTWorkoutModel *)modelForWorkout:(BTWorkout *)workout {
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
    return workoutModel;
}

+ (BTWorkout *)workoutForModel:(BTWorkoutModel *)workoutModel {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
    return workout;
}

@end
