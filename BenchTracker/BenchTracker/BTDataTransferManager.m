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
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BT1RMCalculator.h"
#import "BTAchievement+CoreDataClass.h"

#define DATA_TRANSFER_VERSION 5

@implementation BTDataTransferManager

+ (NSString *)pathForJSONDataExport {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTDataTransferModel *transferModel = [[BTDataTransferModel alloc] init];
    transferModel.version = DATA_TRANSFER_VERSION;
    //SERIALIZE USER
    BTUserModel *userModel = [[BTUserModel alloc] init];
    BTUser *user = [BTUser sharedInstance];
    userModel.dateCreated = user.dateCreated;
    userModel.name = user.name;
    userModel.achievementListVersion = [NSNumber numberWithInt:user.achievementListVersion];
    userModel.xp = [NSNumber numberWithInt:user.xp];
    userModel.imageData = [[NSString alloc] initWithData:user.imageData encoding:NSUTF8StringEncoding];
    userModel.weight = [NSNumber numberWithInt:user.weight];
    userModel.totalDuration = [NSNumber numberWithLongLong:user.totalDuration];
    userModel.totalSets = [NSNumber numberWithLongLong:user.totalSets];
    userModel.totalExercises = [NSNumber numberWithLongLong:user.totalExercises];
    userModel.totalVolume = [NSNumber numberWithLongLong:user.totalVolume];
    userModel.totalWorkouts = [NSNumber numberWithLongLong:user.totalWorkouts];
    userModel.currentStreak = [NSNumber numberWithLongLong:user.currentStreak];
    userModel.longestStreak = [NSNumber numberWithLongLong:user.longestStreak];
    transferModel.user = userModel;
    //SERIALIZE SETTINGS
    BTSettingsModel *settingsModel = [[BTSettingsModel alloc] init];
    BTSettings *settings = [BTSettings sharedInstance];
    settingsModel.startWeekOnMonday = settings.startWeekOnMonday;
    settingsModel.disableSleep = settings.disableSleep;
    settingsModel.weightInLbs = settings.weightInLbs;
    settingsModel.showWorkoutDetails = settings.showLastWorkout;
    settingsModel.showEquivalencyChart = settings.showEquivalencyChart;
    settingsModel.showSmartNames = settings.showSmartNames;
    settingsModel.smartNicknames = [NSKeyedUnarchiver unarchiveObjectWithData:settings.smartNicknames];
    settingsModel.showLastWorkout = settings.showLastWorkout;
    settingsModel.bodyweightIsVolume = settings.bodyweightIsVolume;
    settingsModel.bodyweightMultiplier = [NSNumber numberWithFloat:settings.bodyweightMultiplier];
    transferModel.settings = settingsModel;
    //SERIALIZE TYPELIST
    transferModel.typeList = [BTExerciseType typeListModel];
    //SERIALIZE TEMPLATELIST
    transferModel.templateList = [BTWorkoutTemplate templateListModel];
    //SERIALIZE WORKOUTS
    NSFetchRequest *request = [BTWorkout fetchRequest];
    request.fetchLimit = 0;
    request.fetchBatchSize = 0;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    NSArray *arr = [context executeFetchRequest:request error:nil];
    transferModel.workouts = (NSMutableArray <BTWorkoutModel *> <BTWorkoutModel> *)[NSMutableArray array];
    for (BTWorkout *workout in arr) [transferModel.workouts addObject:[BTDataTransferManager modelForWorkout:workout]];
    //SERIALIZE ACHIEVEMENTS
    transferModel.achievements = [BTAchievement completedAchievementKeys];
    //SAVE TO FILE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/WeightliftingAppData.wld", paths.firstObject];
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
    if (transferModel.version != DATA_TRANSFER_VERSION) return NO;
    //PARSE USER
    BTUser *user = [BTUser sharedInstance];
    user.dateCreated = transferModel.user.dateCreated;
    user.name = transferModel.user.name;
    user.imageData = [transferModel.user.imageData dataUsingEncoding:NSUTF8StringEncoding];
    user.achievementListVersion = transferModel.user.achievementListVersion.intValue;
    user.weight = transferModel.user.weight.intValue;
    user.xp = transferModel.user.xp.intValue;
    user.totalDuration = transferModel.user.totalDuration.integerValue;
    user.totalVolume = transferModel.user.totalVolume.integerValue;
    user.totalSets = transferModel.user.totalSets.integerValue;
    user.totalExercises = transferModel.user.totalExercises.integerValue;
    user.totalWorkouts = transferModel.user.totalWorkouts.integerValue;
    user.currentStreak = transferModel.user.currentStreak.integerValue;
    user.longestStreak = transferModel.user.longestStreak.integerValue;
    //PARSE SETTINGS
    BTSettings *settings = [BTSettings sharedInstance];
    [settings reset];
    settings.startWeekOnMonday = transferModel.settings.startWeekOnMonday;
    settings.weightInLbs = transferModel.settings.weightInLbs;
    settings.disableSleep = transferModel.settings.disableSleep;
    settings.showSmartNames = transferModel.settings.showSmartNames;
    settings.smartNicknames = [NSKeyedArchiver archivedDataWithRootObject:transferModel.settings.smartNicknames];
    settings.showWorkoutDetails = transferModel.settings.showLastWorkout;
    settings.showEquivalencyChart = transferModel.settings.showEquivalencyChart;
    settings.showLastWorkout = transferModel.settings.showLastWorkout;
    settings.bodyweightIsVolume = transferModel.settings.bodyweightIsVolume;
    settings.bodyweightMultiplier = transferModel.settings.bodyweightMultiplier.floatValue;
    //PARSE TYPELIST
    [BTExerciseType resetTypeList];
    [BTExerciseType loadTypeListModel:transferModel.typeList];
    //PARSE TEMPLATELIST
    [BTWorkoutTemplate resetTemplateList];
    [BTWorkoutTemplate loadTemplateListModel:transferModel.templateList];
    //PARSE WORKOUTS
    [BTWorkout resetWorkouts];
    for (BTWorkoutModel *workoutModel in transferModel.workouts)
        [BTDataTransferManager workoutForModel:workoutModel];
    //PARSE ACHIEVEMENTS
    [BTAchievement resetAchievementList];
    [BTAchievement checkAchievementList];
    for (NSString *key in transferModel.achievements) [BTAchievement markAchievementComplete:key animated:NO];
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
    workoutModel.duration = [NSNumber numberWithInteger:(int)workout.duration];
    workoutModel.exercises = (NSMutableArray <BTExerciseModel *><BTExerciseModel> *)[NSMutableArray array];
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
    workout.factoredIntoTotals = YES;
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
        [exercise calculateVolume];
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
