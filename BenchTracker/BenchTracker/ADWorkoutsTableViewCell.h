//
//  ADWorkoutsTableViewCell.h
//  BenchTracker
//
//  Created by Student User on 1/14/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTStackedBarView.h"

#define QUERY_TYPE_VOLUME       0
#define QUERY_TYPE_DURATION     1
#define QUERY_TYPE_NUMEXERCISES 2
#define QUERY_TYPE_NUMSETS      3

@class BTWorkout;

@interface ADWorkoutsTableViewCell : UITableViewCell <BTStackedBarViewDataSource>

@property (nonatomic) NSInteger type;
@property (nonatomic) BTWorkout *workout;

@property (nonatomic) NSString *weightSuffix;

@end
