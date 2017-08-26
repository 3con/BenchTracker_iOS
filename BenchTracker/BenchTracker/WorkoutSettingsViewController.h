//
//  WorkoutSettingsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTWorkout;
@class BTSettings;
@class WorkoutSettingsViewController;

@protocol WorkoutSettingsViewControllerDelegate <NSObject>
- (void)WorkoutSettingsViewControllerWillDismiss:(WorkoutSettingsViewController *)wsVC;
@end

@interface WorkoutSettingsViewController : UIViewController <UIScrollViewDelegate, UIPrintInteractionControllerDelegate>

@property (nonatomic) id<WorkoutSettingsViewControllerDelegate> delegate;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTWorkout *workout;

@property (nonatomic) CGPoint point;

@end
