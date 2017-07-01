//
//  WorkoutTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/30/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTStackedBarView.h"

@class BTWorkout;

@interface WorkoutTableViewCell : UITableViewCell <BTStackedBarViewDataSource>

- (void)loadWorkout:(BTWorkout *)workout;

@end
