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
#import "SettingsViewController.h"
#import "WeekdayView.h"
#import "FSCalendar.h"
#import "SWTableViewCell.h"

@interface MainViewController : UIViewController <WorkoutViewControllerDelegate, SettingsViewControllerDelegate, LoginViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, SWTableViewCellDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet WeekdayView *weekdayView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@end
