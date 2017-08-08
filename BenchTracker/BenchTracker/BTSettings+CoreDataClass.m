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
    self.activeWorkoutStartDate = nil;
    self.hiddenExerciseTypeSections = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
    self.exerciseTypeColors = nil;
    self.startWeekOnMonday = YES;
    self.disableSleep = YES;
    self.weightInLbs = ![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

- (NSString *)weightSuffix {
    return (self.weightInLbs) ? @"lbs" : @"kg";
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
        settings.activeWorkout = nil;
        settings.activeWorkoutStartDate = nil;
        settings.hiddenExerciseTypeSections = [NSKeyedArchiver archivedDataWithRootObject:[NSMutableArray array]];
        settings.exerciseTypeColors = nil;
        settings.startWeekOnMonday = YES;
        settings.disableSleep = YES;
        settings.weightInLbs = ![[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
        [context save:nil];
        return settings;
    }
    return object[0];
}

@end
