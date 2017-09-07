//
//  BTAchievement+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import "BTAchievement+CoreDataClass.h"
#import "AchievementListVersionModel.h"
#import "AchievementListModel.h"
#import "BTUser+CoreDataClass.h"
#import "AppDelegate.h"

@implementation BTAchievement

- (UIImage *)image {
    return [UIImage imageNamed:@"firstWorkout"];
    return [UIImage imageNamed:self.key];
}

- (void)setColor:(UIColor *)color {
    self.colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
}

- (UIColor *)color {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.colorData];
}

#pragma mark - public methods

//achievement list handling

+ (void)checkAchievementList {
    [BTUser sharedInstance].achievementListVersion = 0; //UNCOMMENT TO FORCE RELOAD ACHIEVEMENTS
    //CHECK VERSION
    BOOL reloadAchievements = NO;
    NSError *error = nil;
    NSString *JSONString = [[NSString alloc] initWithData:[[NSDataAsset alloc] initWithName:@"AchievementList"].data
                                                 encoding:NSUTF8StringEncoding];
    AchievementListVersionModel *vModel = [[AchievementListVersionModel alloc] initWithString:JSONString error:&error];
    reloadAchievements = (!vModel || vModel.version > [BTUser sharedInstance].achievementListVersion);
    //CHECK FOR EXISTING ACHIEVEMENTS
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTAchievement fetchRequest];
    request.fetchLimit = 1;
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error) NSLog(@"BTAchievementManager error: %@",error);
    else if (!object || object.count == 0 || reloadAchievements) {
        NSLog(@"No achievements / update needed, loading list");
        AchievementListModel *model = [[AchievementListModel alloc] initWithString:JSONString error:&error];
        if (error) NSLog(@"typeList JSON model error:%@",error);
        else [BTAchievement loadAchievementListModel:model];
    }
}

+ (void)resetAchievementList {
    [BTUser sharedInstance].xp = 0;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTAchievement *achievement in [BTAchievement allAchievements])
        [context deleteObject:achievement];
    [context save:nil];
}

//data transfer model

+ (void)loadAchievementListModel:(AchievementListModel *)model {
    NSArray <NSString *> *completedAchievements = [BTAchievement completedAchievementKeys];
    [BTAchievement resetAchievementList];
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (AchievementModel *aModel in model.achievements) {
        BTAchievement *achievement = [NSEntityDescription insertNewObjectForEntityForName:@"BTAchievement" inManagedObjectContext:context];
        achievement.name = aModel.name;
        achievement.details = aModel.details;
        achievement.key = aModel.key;
        achievement.xp = aModel.xp.intValue;
        achievement.hidden = aModel.hidden;
        achievement.completed = [completedAchievements containsObject:aModel.key];
        if (achievement.completed) [BTUser sharedInstance].xp += achievement.xp;
        achievement.color = (aModel.color) ? [BTAchievement colorForHex:aModel.color] : nil;
    }
    [context save:nil];
}

+ (NSArray <NSString *> *)completedAchievementKeys {
    NSMutableArray *arr = [NSMutableArray array];
    for (BTAchievement *achievement in [BTAchievement allAchievements])
        if (achievement.completed) [arr addObject:achievement.key];
    return arr;
}

//individual achievements

+ (void)markAchievementComplete:(NSString *)key animated:(BOOL)animated { //also in charge of displaying toast
    BTAchievement *achievement = [BTAchievement achievementWithKey:key];
    if (achievement && !achievement.completed) {
        [BTUser sharedInstance].xp += achievement.xp;
        achievement.completed = YES;
        if (animated) {
            //DISPLAY TOAST ON CURRENT SCREEN
        }
    }
}

#pragma mark - private methods

+ (NSArray <BTAchievement *> *)allAchievements {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTAchievement fetchRequest];
    request.fetchLimit = 0;
    request.fetchBatchSize = 0;
    return [context executeFetchRequest:request error:nil];
}

+ (BTAchievement *)achievementWithKey:(NSString *)key {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTAchievement fetchRequest];
    request.fetchLimit = 1;
    NSArray *a = [context executeFetchRequest:request error:nil];
    return (a && a.count > 0) ? a.firstObject : nil;
}

+ (UIColor *)colorForHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
