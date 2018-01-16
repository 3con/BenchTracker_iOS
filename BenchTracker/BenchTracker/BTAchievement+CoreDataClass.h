//
//  BTAchievement+CoreDataClass.h
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

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

@class NSObject;
@class AchievementListModel;
@class BTWorkout;

NS_ASSUME_NONNULL_BEGIN

@interface BTAchievement : NSManagedObject

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic) UIColor *color;

//achievement checking

+ (void)updateAchievementsWithWorkout:(BTWorkout *)workout;

+ (void)markAchievementComplete:(NSString *)key animated:(BOOL)animated; //also in charge of displaying toast

//badge handling

+ (NSInteger)numberOfUnreadAchievements;

+ (void)resetUnreadAcheivements;

//achievement list handling

+ (void)checkAchievementList;

+ (void)resetAchievementList;

//data transfer model

+ (void)loadAchievementListModel:(AchievementListModel *)model;

+ (NSArray <NSString *> *)completedAchievementKeys;

@end

NS_ASSUME_NONNULL_END

#import "BTAchievement+CoreDataProperties.h"
