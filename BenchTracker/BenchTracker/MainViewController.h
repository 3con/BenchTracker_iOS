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
#import "FSCalendar.h"

@interface MainViewController : UIViewController <WorkoutViewControllerDelegate, SettingsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate,  FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@end
