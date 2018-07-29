//
//  WorkoutViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTWorkout+CoreDataClass.h"
#import "AddExerciseViewController.h"
#import "ExerciseViewController.h"
#import "WorkoutSettingsViewController.h"
#import "MGSwipeTableCell.h"
#import "AdjustTimesViewController.h"

@class WorkoutViewController;

@protocol WorkoutViewControllerDelegate <NSObject>
@required
- (void) workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout;
- (void) workoutViewController:(WorkoutViewController *)workoutVC didDismissWithResultWorkout:(BTWorkout *)workout;
@end

@interface WorkoutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, AddExerciseViewControllerDelegate, ExerciseViewControllerDelegate, MGSwipeTableCellDelegate, UIGestureRecognizerDelegate, WorkoutSettingsViewControllerDelegate, AdjustTimesViewControllerDelegate>

@property id<WorkoutViewControllerDelegate> delegate;

@property NSManagedObjectContext *context;
@property BTWorkout *workout;

@end
