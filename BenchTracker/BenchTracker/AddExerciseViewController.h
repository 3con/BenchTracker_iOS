//
//  AddExerciseViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BTExerciseType;
@class AddExerciseViewController;

@protocol AddExerciseViewControllerDelegate <NSObject>
@required
- (void) addExerciseViewController:(AddExerciseViewController *)addVC willDismissWithSelectedTypes:(NSArray <BTExerciseType *> *)selectedTypes;
@end

@interface AddExerciseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property id<AddExerciseViewControllerDelegate> delegate;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *supersetButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;

@end
