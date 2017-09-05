//
//  BTAchievement+CoreDataClass.h
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NSObject;
@class AchievementListModel;

NS_ASSUME_NONNULL_BEGIN

@interface BTAchievement : NSManagedObject

@property (nonatomic) UIImage *image;
@property (nonatomic) UIColor *color;

//achievement list handling

+ (void)checkAchievementList;

+ (void)resetAchievementList;

//data transfer model

+ (void)loadAchievementListModel:(AchievementListModel *)model;

+ (NSArray <NSString *> *)completedAchievements;

//individual achievements

+ (void)markAchievementComplete:(NSString *)key; //also in charge of displaying toast

@end

NS_ASSUME_NONNULL_END

#import "BTAchievement+CoreDataProperties.h"
