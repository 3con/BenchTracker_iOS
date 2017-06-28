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

@interface BTWorkoutManager ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *mapper;
@property (nonatomic, strong) NSManagedObjectContext *context;

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

#pragma mark - client -> server

- (BTWorkout *)createWorkout {
    BTWorkout *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkout" inManagedObjectContext:self.context];
    workout.uuid = [[NSUUID UUID] UUIDString];
    int h = (int)[[[NSCalendar currentCalendar] components:(NSCalendarUnitHour) fromDate:[NSDate date]] hour];
    NSString *timeStr = (h > 22 || h < 4 ) ? @"Dusk" : (h < 11) ? @"Morning" : (h < 1) ? @"Mid Day" : (h < 7) ? @"Afternoon" : @"Evening";
    workout.name = [NSString stringWithFormat:@"%@ Workout",timeStr];
    workout.date = [NSDate date];
    workout.duration = 0;
    workout.summary = @"0";
    workout.exercises = [[NSOrderedSet alloc] init];
    BTAWSWorkout *AWSWorkout = [self AWSWorkoutForWorkout:workout];
    [self pushAWSWorkout:AWSWorkout withCompletionBlock:^{
        
    }];
    [self saveCoreData];
    [self.delegate workoutManager:self didCreateWorkout:workout]; //add to recentEdits list, send new user
    return workout;
}

- (void)saveEditedWorkout: (BTWorkout *)workout {
    BTAWSWorkout *AWSWorkout = [self AWSWorkoutForWorkout:workout];
    [self pushAWSWorkout:AWSWorkout withCompletionBlock:^{
        
    }];
    [self saveCoreData];
    [self.delegate workoutManager:self didCreateWorkout:workout]; //add to recentEdits list, send new user
}

- (void)deleteWorkout: (BTWorkout *)workout {
    [self.delegate workoutManager:self didDeleteWorkout:workout]; //add to recentEdits list, send new user
    BTAWSWorkout *AWSWorkout = [BTAWSWorkout new];
    AWSWorkout.uuid = workout.uuid;
    [self.mapper remove:AWSWorkout completionHandler:^(NSError * _Nullable error) {
        if (error)NSLog(@"workoutManager error: %@",error);
    }];
    [self.context deleteObject:workout];
    [self saveCoreData];
}

#pragma mark - server -> client

- (void)updateWorkoutsWithRecentEdits: (NSMutableArray<NSString *>*)recentEdits {
    //ASYNC
    
    //go through array to identify all changes
    //     ---> if change end not found, delete all CD, download all in user list, convert, add, save
    //trim out irrelevent changes
    //go through each change:
    //   D: delete from CD
    //   E: delete from CD, download, convert, add
    //   A: download, convert, add
    //save to CoreData
    //optional: checksum to make sure CD and user workout list are same length
}

#pragma mark - private methods

- (BTAWSWorkout *)AWSWorkoutForWorkout: (BTWorkout *)workout {
    BTAWSWorkout *AWSWorkout = [BTAWSWorkout new];
    AWSWorkout.uuid = workout.uuid;
    AWSWorkout.name = workout.name;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    AWSWorkout.date = [dateFormatter stringFromDate:workout.date];
    AWSWorkout.duration = [NSNumber numberWithInteger:workout.duration];
    AWSWorkout.summary = workout.summary;
    AWSWorkout.exercises = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in workout.exercises) {
        NSString *r = @"{";
        r = [NSString stringWithFormat:@"%@\"style\":\"%@\",",r, exercise.style];
        r = [NSString stringWithFormat:@"%@\"name\":\"%@\",",r, exercise.name];
        r = [NSString stringWithFormat:@"%@\"iteration\":\"%@\",",r, exercise.iteration];
        r = [NSString stringWithFormat:@"%@\"category\":\"%@\",",r, exercise.category];
        r = [NSString stringWithFormat:@"%@\"sets\":\"%@\",",r, exercise.sets];
        [AWSWorkout.exercises addObject:[NSString stringWithFormat:@"%@}",r]];
    }
    if (AWSWorkout.exercises.count == 0) [AWSWorkout.exercises addObject:AWS_EMPTY];
    return AWSWorkout;
}

- (void)pushAWSWorkout:(BTAWSWorkout *)AWSWorkout withCompletionBlock:(void (^)())completed {
    [[self.mapper save:AWSWorkout] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"workoutManager push error: [%@]", task.error);
        else completed();
        return nil;
    }];
}


/*
 @property (nonatomic, nonnull)                   NSString* uuid;
 @property (nonatomic, nonnull)                   NSString* name;
 @property (nonatomic, nonnull)                   NSString* date;
 @property (nonatomic, nonnull)                   NSNumber* duration;
 @property (nonatomic, nonnull)                   NSString* summary;
 @property (nonatomic, nonnull) NSMutableArray<NSString *>* exercises;
 */

/*
 @property (nullable, nonatomic, retain) NSData *sets;
 @property (nullable, nonatomic, copy) NSString *style;
 @property (nullable, nonatomic, copy) NSString *name;
 @property (nullable, nonatomic, copy) NSString *iteration;
 @property (nullable, nonatomic, copy) NSString *category;
 */

- (void)saveCoreData {
    NSError *error;
    [self.context save:&error];
    if(error) NSLog(@"workoutManager error: %@",error);
}

@end
