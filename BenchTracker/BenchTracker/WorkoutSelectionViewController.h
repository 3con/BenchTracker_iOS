//
//  WorkoutSelectionViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class WorkoutSelectionViewController;
@class BTWorkoutManager;
@class BTWorkout;
@protocol MGSwipeTableCellDelegate;

@protocol WorkoutSelectionViewControllerDelegate <NSObject>
- (void)workoutSelectionVC:(WorkoutSelectionViewController *)wsVC didDismissWithSelectedWorkout:(BTWorkout *)workout;
@end

@interface WorkoutSelectionViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic) id<WorkoutSelectionViewControllerDelegate, MGSwipeTableCellDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTWorkoutManager *workoutManager;

@property (nonatomic) CGPoint originPoint;
@property (nonatomic) NSDate *date;

@end
