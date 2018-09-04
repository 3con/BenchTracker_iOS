//
//  WorkoutSettingsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRDisplayViewController.h"
#import "AdjustTimesViewController.h"

@class BTWorkout;
@class BTSettings;
@class WorkoutSettingsViewController;

@protocol WorkoutSettingsViewControllerDelegate <NSObject>
- (void)WorkoutSettingsViewControllerWillDismiss:(WorkoutSettingsViewController *)wsVC;
- (UIImage *)imageToShare;
@end

@interface WorkoutSettingsViewController : UIViewController <UIScrollViewDelegate, UIPrintInteractionControllerDelegate, QRDisplayViewControllerDelegate, AdjustTimesViewControllerDelegate>

@property (nonatomic) id<WorkoutSettingsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTWorkout *workout;
@property (nonatomic) CGPoint point;

@end
