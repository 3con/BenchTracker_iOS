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
#import "BTSettings+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"

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
    NSArray *arr = [context executeFetchRequest:request error:nil];
    transferModel.workouts = [NSMutableArray array];
    for (BTWorkout *workout in arr) [transferModel.workouts addObject:[BTWorkout jsonForWorkout:workout]];
    //SAVE TO FILE
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/BenchTrackerData.btd", paths.firstObject];
    [[transferModel toJSONString] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return path;
}

+ (BOOL)loadJSONDataWithURL:(NSURL *)url {
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
    for (NSString *workoutString in transferModel.workouts)
        [BTWorkout workoutForJSON:workoutString];
    return true;
}

@end
