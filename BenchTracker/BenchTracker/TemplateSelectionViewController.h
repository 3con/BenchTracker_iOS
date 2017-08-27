//
//  TemplateSelectionViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MGSwipeTableCell.h"

@class BTWorkout;
@class BTSettings;
@class TemplateSelectionViewController;

@protocol TemplateSelectionViewControllerDelegate <NSObject>
- (void)templateSelectionViewController:(TemplateSelectionViewController *)tsVC didDismissWithSelectedWorkout:(BTWorkout *)workout;
@end

@interface TemplateSelectionViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, MGSwipeTableCellDelegate>

@property (nonatomic) id<TemplateSelectionViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@property (nonatomic) BTSettings *settings;

@end
