//
//  MainViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "WorkoutViewController.h"
#import "WorkoutSelectionViewController.h"
#import "BTQRScannerViewController.h"
#import "AnalyticsViewController.h"
#import "WeekdayView.h"
#import "FSCalendar.h"
#import "SWTableViewCell.h"

@interface MainViewController : UIViewController <WorkoutViewControllerDelegate, LoginViewControllerDelegate, AnalyticsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, SWTableViewCellDelegate, WeekdayViewDelegate, BTQRScannerViewControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet WeekdayView *weekdayView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@property (weak, nonatomic) IBOutlet UIButton *scanWorkoutButton;

@end
