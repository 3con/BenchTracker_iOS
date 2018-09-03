//
//  BTSettings+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 7/1/17.
//
//

#import "BTSettings+CoreDataClass.h"
#import "AppDelegate.h"

@implementation BTSettings

+ (BTSettings *)sharedInstance {
    static BTSettings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self fetchSettings];
    });
    return sharedInstance;
}

- (void)reset {
    self.activeWorkout = nil;
    self.activeWorkoutLastUpdate = nil;
    self.activeWorkoutBeforeDuration = 0;
    self.hiddenExerciseTypeSections = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    self.exerciseTypeColors = nil;
    self.showSmartNames = YES;
    self.smartNicknames = nil;
    self.startWeekOnMonday = YES;
    self.disableSleep = YES;
    self.showWorkoutDetails = YES;
    self.showEquivalencyChart = YES;
    self.showLastWorkout = YES;
    self.weightInLbs = ![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
    self.bodyweightIsVolume = NO;
    self.bodyweightMultiplier = 1.0;
}

- (NSString *)weightSuffix {
    return (self.weightInLbs) ? @"lbs" : @"kg";
}

- (NSDictionary *)smartNicknameDict {
    if (self.smartNicknames) return [NSKeyedUnarchiver unarchiveObjectWithData:self.smartNicknames];
    NSDictionary *dict = @{@"abs": @"Shredded Abs 😜",
                           @"arms": @"Arm Workout 💪",
                           @"back": @"Back Day 😤",
                           @"cardio": @"Cardio 🏃‍♂️",
                           @"chest": @"Chest Day 🙌",
                           @"legs": @"Leg Day 🏋️",
                           @"shoulders": @"Shoulder Workout 😁",
                           @"pull": @"Pull Day 👇",
                           @"push": @"Push Day 👆",
                           @"chestBack": @"Chest and Back 😊",
                           @"chestBiceps": @"Chest and Biceps 💪",
                           @"fullBody": @"Full Body Workout 🏋️" };
    self.smartNicknames = [NSKeyedArchiver archivedDataWithRootObject:dict];
    return dict;
}

- (void)setNickname:(NSString *)nickname forSmartName:(NSString *)key {
    NSMutableDictionary *dict = [self smartNicknameDict].mutableCopy;
    if (dict[key] != nil) dict[key] = nickname;
    self.smartNicknames = [NSKeyedArchiver archivedDataWithRootObject:dict];
}

#pragma mark - private methods

+ (BTSettings *)fetchSettings {
    NSFetchRequest *request = [BTSettings fetchRequest];
    request.fetchLimit = 1;
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error || object.count == 0) {
        NSLog(@"BTSettings coreData error or creation: %@",error);
        BTSettings *settings = [NSEntityDescription insertNewObjectForEntityForName:@"BTSettings" inManagedObjectContext:context];
        [settings reset];
        [context save:nil];
        return settings;
    }
    return object[0];
}

@end
