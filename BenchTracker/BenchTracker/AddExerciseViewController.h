//
//  AddExerciseViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "IterationSelectionViewController.h"
#import "AETableHeaderView.h"

@class BTExerciseType;
@class AddExerciseViewController;

@protocol AddExerciseViewControllerDelegate <NSObject>
@required
- (void) addExerciseViewController:(AddExerciseViewController *)addVC willDismissWithSelectedTypeIterationCombinations:(NSArray <NSArray *> *)selectedTypeIterationCombinations superset:(BOOL)superset;
@end

@interface AddExerciseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate, IterationSelectionViewControllerDelegate, UIScrollViewDelegate, AETableHeaderViewDelegate>

@property id<AddExerciseViewControllerDelegate> delegate;

@property NSManagedObjectContext *context;

@end
