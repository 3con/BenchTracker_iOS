//
//  AchievementCollectionViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/7/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCollectionViewCell.h"

@class BTAchievement;

@interface AchievementCollectionViewCell : BTCollectionViewCell

- (void)loadWithAchievement:(BTAchievement *)achievement;

@end
