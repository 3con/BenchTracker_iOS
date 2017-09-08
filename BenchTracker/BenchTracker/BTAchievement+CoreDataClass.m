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
#import "UIView+Toast.h"
#import "MainViewController.h"

#define ACHIEVEMENT_FIRSTWORKOUT @"firstWorkout"
#define ACHIEVEMENT_SPEED0 @"speed0"
#define ACHIEVEMENT_SPEED1 @"speed1"
#define ACHIEVEMENT_SPEED2 @"speed2"
#define ACHIEVEMENT_SPEED9 @"speed9"
#define ACHIEVEMENT_IRON1 @"iron1"
#define ACHIEVEMENT_IRON15 @"iron15"
#define ACHIEVEMENT_IRON2 @"iron2"
#define ACHIEVEMENT_IRON3 @"iron3"
#define ACHIEVEMENT_IRON9 @"iron9"
#define ACHIEVEMENT_LIGHT0 @"light0"
#define ACHIEVEMENT_LIGHT1 @"light1"
#define ACHIEVEMENT_HEAVY1 @"heavy1"
#define ACHIEVEMENT_HEAVY2 @"heavy2"
#define ACHIEVEMENT_HEAVY3 @"heavy3"
#define ACHIEVEMENT_HEAVY4 @"heavy4"
#define ACHIEVEMENT_HEAVY9 @"heavy9"
#define ACHIEVEMENT_SETS1 @"sets1"
#define ACHIEVEMENT_SETS2 @"sets2"
#define ACHIEVEMENT_SETS3 @"sets3"
#define ACHIEVEMENT_SETS9 @"sets9"
#define ACHIEVEMENT_STRONG1 @"strong1"
#define ACHIEVEMENT_STRONG2 @"strong2"
#define ACHIEVEMENT_STRONG3 @"strong3"
#define ACHIEVEMENT_STRONG9 @"strong9"
#define ACHIEVEMENT_SUPER1 @"super1"
#define ACHIEVEMENT_SUPER2 @"super2"
#define ACHIEVEMENT_SUPER9 @"super9"
#define ACHIEVEMENT_TIME0 @"time0"
#define ACHIEVEMENT_TIME1 @"time1"
#define ACHIEVEMENT_TIME2 @"time2"
#define ACHIEVEMENT_TYPES1 @"types1"
#define ACHIEVEMENT_TYPES2 @"types2"
#define ACHIEVEMENT_TYPES3 @"types3"
#define ACHIEVEMENT_MARATHON1 @"marathon1"
#define ACHIEVEMENT_MARATHON2 @"marathon2"
#define ACHIEVEMENT_MARATHON3 @"marathon3"
#define ACHIEVEMENT_MARATHON4 @"marathon4"
#define ACHIEVEMENT_MARATHON5 @"marathon5"
#define ACHIEVEMENT_GAINS1 @"gains1"
#define ACHIEVEMENT_GAINS2 @"gains2"
#define ACHIEVEMENT_GAINS3 @"gains3"
#define ACHIEVEMENT_GAINS4 @"gains4"
#define ACHIEVEMENT_GAINS5 @"gains5"
#define ACHIEVEMENT_STREAK1 @"streak1"
#define ACHIEVEMENT_STREAK2 @"streak2"
#define ACHIEVEMENT_STREAK3 @"streak3"
#define ACHIEVEMENT_STREAK4 @"streak4"
#define ACHIEVEMENT_DEDICATION1 @"dedication1"
#define ACHIEVEMENT_DEDICATION2 @"dedication2"
#define ACHIEVEMENT_DEDICATION3 @"dedication3"
#define ACHIEVEMENT_DEDICATION4 @"dedication4"
#define ACHIEVEMENT_DEDICATION15 @"dedication15"
#define ACHIEVEMENT_POWER1 @"power1"
#define ACHIEVEMENT_POWER2 @"power2"
#define ACHIEVEMENT_POWER3 @"power3"
#define ACHIEVEMENT_POWER4 @"power4"
#define ACHIEVEMENT_POWER5 @"power5"
#define ACHIEVEMENT_POWER9 @"power9"
#define ACHIEVEMENT_EVERYCATEGORY @"everyCategory"
#define ACHIEVEMENT_CREATE1 @"create1"
#define ACHIEVEMENT_CREATE2 @"create2"
#define ACHIEVEMENT_SHARE @"share"
#define ACHIEVEMENT_ANALYZE @"analyze"
#define ACHIEVEMENT_TEMPLATE @"template"
#define ACHIEVEMENT_PRINT @"print"
#define ACHIEVEMENT_SCAN @"scan"

@implementation BTAchievement

- (UIImage *)image {
    return [UIImage imageNamed:self.key];
}

- (void)setColor:(UIColor *)color {
    self.colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
}

- (UIColor *)color {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.colorData];
}

#pragma mark - public methods

//achievement checking

+ (void)updateAchievementsWithWorkout:(BTWorkout *)workout {
    [self markAchievementComplete:ACHIEVEMENT_SCAN animated:YES];
    [self markAchievementComplete:ACHIEVEMENT_IRON1 animated:YES];
    [self markAchievementComplete:ACHIEVEMENT_FIRSTWORKOUT animated:YES];
}

+ (void)markAchievementComplete:(NSString *)key animated:(BOOL)animated { //also in charge of displaying toast
    BTAchievement *achievement = [BTAchievement achievementWithKey:key];
    achievement.completed = NO;
    if (achievement && !achievement.completed) {
        [BTUser sharedInstance].xp += achievement.xp;
        achievement.completed = YES;
        if (animated) {
            UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.backgroundColor = [UIColor BTVibrantColors][0];
            style.cornerRadius = 12;
            style.verticalPadding = 20;
            style.horizontalPadding = 20;
            style.titleFont = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            style.messageFont = [UIFont systemFontOfSize:21 weight:UIFontWeightSemibold];
            style.titleAlignment = NSTextAlignmentCenter;
            style.messageAlignment = NSTextAlignmentCenter;
            style.maxWidthPercentage = 90;
            style.imageSize = CGSizeMake(80, 80);
            style.fadeDuration = .25;
            [viewController.view makeToast:achievement.name duration:2.0 position:CSToastPositionTop
                title:@"Achivement Unlocked:" image:achievement.image style:style completion:^(BOOL didTap) {
                    if (didTap && [viewController isKindOfClass:[MainViewController class]])
                        [(MainViewController *)viewController presentUserViewController];
            }];
        }
    }
}

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
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"key == '%@'",key]];
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
