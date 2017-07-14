//
//  ADMuscleSplitTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTWorkout;

@interface ADMuscleSplitTableViewCell : UITableViewCell

@property (nonatomic) UIColor *color;

- (void)loadWithDate:(NSDate *)date workouts:(NSArray <BTWorkout *> *)workouts weightSuffix:(NSString *)suffix;

@end
