//
//  WorkoutSettingsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRDisplayViewController.h"

@class BTWorkout;
@class BTSettings;
@class WorkoutSettingsViewController;

@protocol WorkoutSettingsViewControllerDelegate <NSObject>
- (void)WorkoutSettingsViewControllerWillDismiss:(WorkoutSettingsViewController *)wsVC;
@end

@interface WorkoutSettingsViewController : UIViewController <UIScrollViewDelegate, UIPrintInteractionControllerDelegate, QRDisplayViewControllerDelegate>

@property (nonatomic) id<WorkoutSettingsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTWorkout *workout;

@property (nonatomic) CGPoint point;

@end
