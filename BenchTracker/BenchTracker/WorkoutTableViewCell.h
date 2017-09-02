//
//  WorkoutTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/30/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTStackedBarView.h"
#import "MGSwipeTableCell.h"

@class BTWorkout;

@interface WorkoutTableViewCell : MGSwipeTableCell <BTStackedBarViewDataSource>

@property (nonatomic) NSDictionary *exerciseTypeColors;

- (void)loadWorkout:(BTWorkout *)workout;

+ (CGFloat)heightForWorkoutCell;

- (void)checkTemplateStatus;

@end
