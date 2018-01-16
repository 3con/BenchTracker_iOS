//
//  BTCalendarCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <FSCalendar/FSCalendar.h>
#import "BTStackedBarView.h"

@class BTWorkout;

@interface BTCalendarCell : FSCalendarCell <BTStackedBarViewDataSource>

@property (nonatomic) NSDate *date;

@property (nonatomic) NSMutableDictionary *exerciseTypeColors;

- (void)loadWithWorkouts:(NSArray <BTWorkout *> *)workouts;

@end
