//
//  AchievementDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTAchievement;

@interface AchievementDetailViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) BTAchievement *achievement;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic) UIColor *color;

@end
