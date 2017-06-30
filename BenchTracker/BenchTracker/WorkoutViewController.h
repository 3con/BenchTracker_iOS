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

@class WorkoutViewController;

@protocol WorkoutViewControllerDelegate <NSObject>
@required
- (void) workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout;
@end

@interface WorkoutViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, AddExerciseViewControllerDelegate, ExerciseViewControllerDelegate>

@property id<WorkoutViewControllerDelegate> delegate;

@property NSManagedObjectContext *context;
@property BTWorkout *workout;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
