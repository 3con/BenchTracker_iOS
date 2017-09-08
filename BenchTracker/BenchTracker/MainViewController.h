//
//  MainViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutViewController.h"
#import "WorkoutSelectionViewController.h"
#import "UserViewController.h"
#import "BTQRScannerViewController.h"
#import "AnalyticsViewController.h"
#import "WeekdayView.h"
#import "MGSwipeTableCell.h"
#import "TemplateSelectionViewController.h"
#import "BTCalendarCell.h"

@interface MainViewController : UIViewController <WorkoutViewControllerDelegate, AnalyticsViewControllerDelegate, WorkoutSelectionViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, MGSwipeTableCellDelegate, WeekdayViewDelegate, BTQRScannerViewControllerDelegate, UserViewControllerDelegate, TemplateSelectionViewControllerDelegate>

@property (nonatomic) NSManagedObjectContext *context;

- (void)presentUserViewController;

@end
