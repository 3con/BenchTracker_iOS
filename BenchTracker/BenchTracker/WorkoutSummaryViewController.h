//
//  WorkoutSummaryViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTWorkout;
@class BTSettings;
@class WorkoutSummaryViewController;

@protocol WorkoutSummaryViewControllerDelegate <NSObject>
- (void)workoutSummaryViewControllerWillDismiss:(WorkoutSummaryViewController *)wsVC;
- (void)workoutSummaryViewControllerDidDismissWithAcheievementShowRequest:(WorkoutSummaryViewController *)wsVC;
@end

@interface WorkoutSummaryViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) id<WorkoutSummaryViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTWorkout *workout;

@end
