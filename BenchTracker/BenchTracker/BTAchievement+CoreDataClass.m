//
//  BTAchievement+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import "BTAchievement+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "AchievementListVersionModel.h"
#import "AchievementListModel.h"
#import "BTUser+CoreDataClass.h"
#import "AppDelegate.h"
#import "MainViewController.h"

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
    CGFloat weightX = [BTSettings sharedInstance].weightInLbs ? 1 : .5;
    if (workout.duration >= 60*10 && workout.numSets > 6)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_FIRSTWORKOUT animated:YES];
    if (workout.duration >= 60*30 && workout.numSets <= 10)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SPEED0 animated:YES];
    if (workout.duration < 60*60) {
        if (workout.numSets >= 25) [BTAchievement markAchievementComplete:ACHIEVEMENT_SPEED1 animated:YES];
        if (workout.numSets >= 30) [BTAchievement markAchievementComplete:ACHIEVEMENT_SPEED2 animated:YES];
        if (workout.numSets >= 40) [BTAchievement markAchievementComplete:ACHIEVEMENT_SPEED9 animated:YES];
    }
    else {
        [BTAchievement markAchievementComplete:ACHIEVEMENT_IRON1 animated:YES];
        if (workout.duration >= 60*69 && workout.duration < 60*70)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_IRON15 animated:YES];
        if (workout.duration >= 60*80)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_IRON2 animated:YES];
        if (workout.duration >= 60*100)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_IRON3 animated:YES];
        if (workout.duration >= 60*150)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_IRON9 animated:YES];
    }
    if (workout.numSets >= 20) {
        if (workout.volume == 0)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_LIGHT0 animated:YES];
        if (workout.volume < 5000*weightX)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_LIGHT1 animated:YES];
    }
    if (workout.volume > 10000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_HEAVY1 animated:YES];
    if (workout.volume > 20000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_HEAVY2 animated:YES];
    if (workout.volume > 30000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_HEAVY3 animated:YES];
    if (workout.volume > 40000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_HEAVY4 animated:YES];
    if (workout.volume > 60000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_HEAVY9 animated:YES];
    if (workout.numSets >= 15)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SETS1 animated:YES];
    if (workout.numSets >= 25)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SETS2 animated:YES];
    if (workout.numSets >= 35)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SETS3 animated:YES];
    if (workout.numSets >= 50)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SETS9 animated:YES];
    NSArray *supersets = [NSKeyedUnarchiver unarchiveObjectWithData:workout.supersets];
    if (supersets.count > 0 && workout.numSets > 6)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_SUPER1 animated:YES];
    if (workout.numSets > 8) {
        for (NSArray *superset in supersets) {
            if (superset.count >= 3)
                [BTAchievement markAchievementComplete:ACHIEVEMENT_SUPER2 animated:YES];
            if (superset.count >= 5)
                [BTAchievement markAchievementComplete:ACHIEVEMENT_SUPER9 animated:YES];
        }
    }
    if (workout.numSets > 6) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:workout.date];
        if (components.hour < 5)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_TIME2 animated:YES];
        else if (components.hour == 5 || components.hour == 6)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_TIME1 animated:YES];
        else if (components.hour == 16 && components.minute == 20)
            [BTAchievement markAchievementComplete:ACHIEVEMENT_TIME0 animated:YES];
    }
    NSInteger groupCount = [workout.summary componentsSeparatedByString:@"#"].count;
    if (groupCount == 1 && workout.numSets > 6)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_TYPES1 animated:YES];
    else if (groupCount >= 4 && workout.numSets > 8)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_TYPES2 animated:YES];
    for (BTExercise *exercise in workout.exercises) {
        if (![exercise.style isEqualToString:STYLE_CUSTOM]) {
            NSArray *sets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
            if (sets.count >= 10)
                [BTAchievement markAchievementComplete:ACHIEVEMENT_TYPES3 animated:YES];
            if ([exercise.style isEqualToString:STYLE_REPSWEIGHT] && exercise.oneRM >= 100) {
                for (NSString *set in sets) {
                    CGFloat weight = [set componentsSeparatedByString:@" "][1].floatValue;
                    if (weight >= 100)
                        [BTAchievement markAchievementComplete:ACHIEVEMENT_STRONG1 animated:YES];
                    if (weight >= 200)
                        [BTAchievement markAchievementComplete:ACHIEVEMENT_STRONG2 animated:YES];
                    if (weight >= 300)
                        [BTAchievement markAchievementComplete:ACHIEVEMENT_STRONG3 animated:YES];
                    if (weight >= 500)
                        [BTAchievement markAchievementComplete:ACHIEVEMENT_STRONG9 animated:YES];
                }
            }
        }
    }
    BTUser *user = [BTUser sharedInstance];
    if (user.totalDuration >= 5*60*60)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_MARATHON1 animated:YES];
    if (user.totalDuration >= 10*60*60)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_MARATHON2 animated:YES];
    if (user.totalDuration >= 50*60*60)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_MARATHON3 animated:YES];
    if (user.totalDuration >= 100*60*60)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_MARATHON4 animated:YES];
    if (user.totalDuration >= 500*60*60)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_MARATHON5 animated:YES];
    if (user.totalDuration >= 50000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_GAINS1 animated:YES];
    if (user.totalDuration >= 100000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_GAINS2 animated:YES];
    if (user.totalDuration >= 500000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_GAINS3 animated:YES];
    if (user.totalDuration >= 1000000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_GAINS4 animated:YES];
    if (user.totalDuration >= 10000000*weightX)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_GAINS5 animated:YES];
    [BTUser updateStreaks];
    if (user.currentStreak >= 3)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_STREAK1 animated:YES];
    if (user.currentStreak >= 7)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_STREAK2 animated:YES];
    if (user.currentStreak >= 14)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_STREAK3 animated:YES];
    if (user.currentStreak >= 30)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_STREAK4 animated:YES];
    if (user.totalWorkouts >= 3)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_DEDICATION1 animated:YES];
    if (user.totalWorkouts >= 10)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_DEDICATION2 animated:YES];
    if (user.totalWorkouts >= 25)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_DEDICATION3 animated:YES];
    if (user.totalWorkouts >= 50)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_DEDICATION4 animated:YES];
    if (user.totalWorkouts >= 69)
        [BTAchievement markAchievementComplete:ACHIEVEMENT_DEDICATION15 animated:YES];
    NSInteger total = [BTExercise powerliftingTotalWeight];
    if (total > 0) {
        [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER1 animated:YES];
        if (total > 600) [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER2 animated:YES];
        if (total > 800) [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER3 animated:YES];
        if (total > 1000) [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER4 animated:YES];
        if (total > 1200) [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER5 animated:YES];
        if (total > 1500) [BTAchievement markAchievementComplete:ACHIEVEMENT_POWER9 animated:YES];
    }
}

+ (void)markAchievementComplete:(NSString *)key animated:(BOOL)animated { //also in charge of displaying toast
    BTAchievement *achievement = [BTAchievement achievementWithKey:key];
    if (achievement && !achievement.completed) {
        [BTUser sharedInstance].xp += achievement.xp;
        achievement.completed = YES;
        [[NSUserDefaults standardUserDefaults] setInteger:[BTAchievement numberOfUnreadAchievements]+1 forKey:@"achievementsCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (animated) {
            UIViewController *viewController = [BTAchievement topMostController];
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.backgroundColor = [UIColor BTVibrantColors][0];
            style.cornerRadius = 12;
            style.verticalPadding = 20;
            style.horizontalPadding = 20;
            style.titleFont = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
            style.messageFont = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            style.titleAlignment = NSTextAlignmentCenter;
            style.messageAlignment = NSTextAlignmentCenter;
            style.maxWidthPercentage = 90;
            style.imageSize = CGSizeMake(80, 80);
            style.fadeDuration = .25;
            NSString *str = [NSString stringWithFormat:@"ACHIEVEMENT UNLOCKED!\n+%d xp (Level %ld)", achievement.xp, [BTUser sharedInstance].level];
            [viewController.view makeToast:str duration:3.0 position:CSToastPositionTop title:achievement.name
                                     image:achievement.image style:style completion:^(BOOL didTap) {
                    if (didTap && [viewController isKindOfClass:[MainViewController class]])
                        [(MainViewController *)viewController presentUserViewController];
            }];
        }
    }
}

//badge handling

+ (NSInteger)numberOfUnreadAchievements {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"achievementsCount"];
}

+ (void)resetUnreadAcheivements {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"achievementsCount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//achievement list handling

+ (void)checkAchievementList {
    //[BTUser sharedInstance].achievementListVersion = 0; //UNCOMMENT TO FORCE RELOAD ACHIEVEMENT LIST
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
    [BTAchievement resetUnreadAcheivements];
    [BTUser sharedInstance].xp = 0;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTAchievement *achievement in [BTAchievement allAchievements])
        [context deleteObject:achievement];
    [context save:nil];
}

//data transfer model

+ (void)loadAchievementListModel:(AchievementListModel *)model {
    //[BTAchievement resetAchievementList]; //UNCOMMENT TO FORCE RELOAD ACHIEVEMENT PROGRESS
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

+ (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) topController = topController.presentedViewController;
    return topController;
}

@end
