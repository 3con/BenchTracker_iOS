//
//  WeekdayTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTStackedBarView.h"
#import "MGSwipeTableCell.h"

@class BTWorkout;

@interface WeekdayTableViewCell : MGSwipeTableCell <BTStackedBarViewDataSource>

@property (nonatomic) BOOL today;

@property (nonatomic) NSDate *date;

@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (nonatomic) NSArray <BTWorkout *> *workouts;

- (bool)checkTemplateStatus;

@end
