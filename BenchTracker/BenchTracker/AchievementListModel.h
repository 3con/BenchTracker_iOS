//
//  AchievementListModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol AchievementModel @end

@interface AchievementModel : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *details;
@property (nonatomic) NSString *key;
@property (nonatomic) NSNumber *xp;
@property (nonatomic) BOOL hidden;
@property (nonatomic) NSString <Optional> *color;

@end

@interface AchievementListModel : JSONModel

@property (nonatomic) NSMutableArray <AchievementModel> *achievements;

@end
