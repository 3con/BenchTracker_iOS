//
//  EditExercisesViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/14/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "EEDetailViewController.h"
#import "MGSwipeTableCell.h"

typedef enum BTEditExercisesSource : NSInteger {
    BTEditExercisesSourceSettings,
    BTEditExercisesSourceWorkout
} BTEditExercisesSource;

@interface EditExercisesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, EEDetailViewControllerDelegate, MGSwipeTableCellDelegate>

@property (nonatomic) BTEditExercisesSource source;
@property (nonatomic) NSManagedObjectContext *context;

@end
