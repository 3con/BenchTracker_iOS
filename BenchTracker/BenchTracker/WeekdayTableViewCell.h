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

- (void)loadDate:(NSDate *)date;

- (void)loadWithWorkouts:(NSArray <BTWorkout *> *)workouts;

@end
