//
//  BTWorkoutManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkoutManager.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTAWSWorkout.h"
#import "AppDelegate.h"
#import "BTUserManager.h"
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
    workout.summary = @"";
    workout.user = [(BTUserManager *)[BTUserManager sharedInstance] user];
    workout.exercises = [[NSOrderedSet alloc] init];
    return workout;
    //convert to AWS workout (keep trimmed to 200)
    //add to recentEdits list
    //send new workout, user
    //save to coreData
}

- (void)saveEditedWorkout: (BTWorkout *)workout {
    //convert to AWS workout (keep trimmed to 200)
    //add to recentEdits list
    //send new workout, user
    //save to coreData
}

- (void)deleteWorkout: (BTWorkout *)workout {
    //add to recentEdits list (keep trimmed to 200)
    //remove workout from AWS
    //send new user
    //remove from CoreData
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



@end
