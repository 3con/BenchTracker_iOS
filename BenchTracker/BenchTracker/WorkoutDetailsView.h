//
//  WorkoutDetailsView.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTWorkout;

@interface WorkoutDetailsView : UIView

- (void)loadWithWorkout:(BTWorkout *)workout;

@end
