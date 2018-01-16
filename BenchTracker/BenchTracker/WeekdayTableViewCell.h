//
//  WeekdayTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTStackedBarView.h"

@class BTWorkout;

@interface WeekdayTableViewCell : UITableViewCell <BTStackedBarViewDataSource>

@property (nonatomic) BOOL today;

@property (nonatomic) NSDate *date;

@property (nonatomic) NSDictionary *exerciseTypeColors;

- (void)loadWithWorkouts:(NSArray <BTWorkout *> *)workouts;

@end
