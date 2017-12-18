//
//  BTUser+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "AWSUsername.h"
#import "AWSLeaderboard.h"
#import "AppDelegate.h"

@interface BTUser ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper *mapper;
@property (nonatomic, strong) AWSUsername *awsUser;
@property (nonatomic, strong) AWSLeaderboard *awsLeaderboard;

@end

@implementation BTUser

@synthesize mapper;
@synthesize awsUser;
@synthesize awsLeaderboard;

- (void)setImage:(UIImage *)image {
    self.imageData = UIImagePNGRepresentation(image);
}

- (UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

- (NSInteger)level { //=X/(10+X/200)+1
    return [BTUser levelForXP:self.xp];
}

- (CGFloat)levelProgress {
    NSInteger currentLevel = self.level;
    if (currentLevel == 1) return self.xp/5.0;
    NSInteger lastLevelXP = 0;
    int xp = self.xp;
    while (!lastLevelXP) {
        if (currentLevel == [BTUser levelForXP:xp]) xp --;
        else lastLevelXP = xp;
    }
    NSInteger nextLevelXP = 0;
    xp = self.xp;
    while (!nextLevelXP) {
        if (currentLevel == [BTUser levelForXP:xp]) xp ++;
        else nextLevelXP = xp;
    }
    return (self.xp-lastLevelXP)/(float)(nextLevelXP-lastLevelXP);
}

+ (BTUser *)sharedInstance {
    static BTUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self fetchUser];
        sharedInstance.mapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
        if (!sharedInstance.name || sharedInstance.name.length == 0) {
            sharedInstance.name = [NSString stringWithFormat:@"User %d", arc4random()%99999999];
            [sharedInstance pushAWSUserWithCompletionBlock:^(BOOL success) { }];
        }
        else {
            [sharedInstance fetchAWSUserWithCompletionBlock:^(BOOL success) {
                [sharedInstance pushAWSUserWithCompletionBlock:^(BOOL success) { }];
            }];
        }
        NSLog(@"%@",sharedInstance.name);
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
    [self runPurgeNumber:0];
}

+ (void)runPurgeNumber:(int)num {
    BTUser *user = [BTUser sharedInstance];
    NSInteger numWorkouts = [BTWorkout numberOfWorkouts];
    if (user.totalWorkouts == numWorkouts) return;
    if (user.totalWorkouts > numWorkouts) [BTUser totalPurge];
    if (num > 5) [BTUser totalPurge];
    NSLog(@"Running short purge");
    for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:YES])
        [BTUser addWorkoutToTotals:workout];
    [self runPurgeNumber:num+1];
}

+ (void)totalPurge {
    NSLog(@"Running total (long) purge");
    NSLog(@"BTUser totals error: this probably shouldn't happen!");
    for (BTWorkout *workout in [BTWorkout allWorkoutsWithFactoredIntoTotalsFilter:NO]) {
        workout.factoredIntoTotals = NO;
        [BTUser addWorkoutToTotals:workout];
    }
}

+ (void)updateStreaks {
    BTUser *user = [BTUser sharedInstance];
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                 fromDate:NSDate.date];
    NSDateComponents *components2 = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                  fromDate:[NSDate.date dateByAddingTimeInterval:-86400]];
    NSDate *today = [NSCalendar.currentCalendar dateFromComponents:components];
    NSDate *yesterday = [NSCalendar.currentCalendar dateFromComponents:components2];
    NSInteger count = 0;
    if ([BTWorkout workoutsBetweenBeginDate:today andEndDate:[today dateByAddingTimeInterval:86400]].count > 0) count = 1;
    if ([BTWorkout workoutsBetweenBeginDate:yesterday andEndDate:[yesterday dateByAddingTimeInterval:86400]].count > 0) count ++;
    else if (!count) {
        user.currentStreak = 0;
        return;
    }
    if (count) {
        int i = 2;
        while (YES) {
            NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                         fromDate:[NSDate.date dateByAddingTimeInterval:-86400*i]];
            NSDate *nDate = [NSCalendar.currentCalendar dateFromComponents:components];
            if ([BTWorkout workoutsBetweenBeginDate:nDate andEndDate:[nDate dateByAddingTimeInterval:86400]].count > 0) count ++;
            else break;
            i++;
        }
    }
    user.currentStreak = count;
    user.longestStreak = MAX(user.currentStreak, user.longestStreak);
}

#pragma mark - server only

- (void)userExistsWithUsername:(NSString *)username continueWithBlock:(void (^)(BOOL exists))completed {
    [[self.mapper load:[awsUser class] hashKey:username rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) NSLog(@"AWSUsername exists error: [%@]", task.error);
        else completed(task.result != nil);
        return nil;
    }];
}

- (void)changeUserToUsername:(NSString *)username continueWithBlock:(void (^)(BOOL success))completed {
    [self deleteAWSUserWithCompletionBlock:^(BOOL success) {
        if (!success) completed(false);
        else {
            self.name = username;
            self.awsUser.username = username;
            [self pushAWSUserWithCompletionBlock:^(BOOL success) {
                completed(success);
            }];
        }
    }];
}

- (void)topLevelsWithCompletionBlock:(void (^)(NSArray<AWSLeaderboard *> *topLevels))completed {
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"valid-experience-index";
    queryExpression.keyConditionExpression = @"valid = :val";
    queryExpression.expressionAttributeValues = @{@":val": @"YES"};
    queryExpression.limit = @99;
    queryExpression.scanIndexForward = @NO;
    [[self.mapper query:[AWSLeaderboard class] expression:queryExpression] continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             NSLog(@"The request failed. Error: [%@]", task.error);
             completed(nil);
         } else {
             AWSDynamoDBPaginatedOutput *output = task.result;
             completed(output.items);
         }
         return nil;
     }];
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

- (void)fetchAWSUserWithCompletionBlock:(void (^)(BOOL success))completed {
    [[self.mapper load:[AWSUsername class] hashKey:self.name rangeKey:nil] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"AWSUsername fetch error: [%@]", task.error);
            completed(NO);
        }
        else {
            if (task.result) { //user exists
                self.awsUser = task.result;
                completed(YES);
            }
            else [self pushAWSUserWithCompletionBlock:^(BOOL success) {
                completed(success);
            }];
        }
        return nil;
    }];
}

- (void)pushAWSUserWithCompletionBlock:(void (^)(BOOL success))completed {
    if (!self.awsUser) {
        self.awsUser = [AWSUsername new];
        self.awsUser.dateCreated = [BTUser stringForDate:[NSDate date]];
        self.awsUser.deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    self.awsUser.lastUpdate = [BTUser stringForDate:[NSDate date]];
    self.awsUser.username = self.name;
    [[self.mapper save:self.awsUser] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"AWSUsername push error: [%@]", task.error);
            completed(NO);
        }
        else completed(YES);
        return nil;
    }];
    if (!self.awsLeaderboard) {
        self.awsLeaderboard = [AWSLeaderboard new];
        self.awsLeaderboard.valid = @"YES";
    }
    self.awsLeaderboard.username = self.name;
    self.awsLeaderboard.experience = [NSNumber numberWithInteger:self.xp];
    [[self.mapper save:self.awsLeaderboard] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"AWSLeaderboard push error: [%@]", task.error);
            completed(NO);
        }
        else completed(YES);
        return nil;
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [context save:nil];
    });
}

- (void)deleteAWSUserWithCompletionBlock:(void (^)(BOOL success))completed {
    [[self.mapper remove:self.awsUser] continueWithBlock:^id _Nullable(AWSTask *task) {
        if (task.error) completed(NO);
        else {
            [[self.mapper remove:self.awsLeaderboard] continueWithBlock:^id _Nullable(AWSTask *task) {
                completed(!task.error);
                return nil;
            }];
        }
        return nil;
    }];
}

+ (NSString *)stringForDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateForString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dateFormatter dateFromString:string];
}

+ (NSInteger)levelForXP:(NSInteger)xp {
    return xp/(10+xp/200)+1;
}

@end
