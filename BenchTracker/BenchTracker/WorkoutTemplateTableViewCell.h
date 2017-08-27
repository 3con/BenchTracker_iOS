//
//  WorkoutTemplateTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/26/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "BTStackedBarView.h"

@class BTWorkoutTemplate;

@interface WorkoutTemplateTableViewCell : MGSwipeTableCell <BTStackedBarViewDataSource>

@property (nonatomic) NSDictionary *exerciseTypeColors;

- (void)loadWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate;

+ (CGFloat)heightForWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate;

@end
