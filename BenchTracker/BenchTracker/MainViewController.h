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
#import "SettingsViewController.h"
#import "BTQRScannerViewController.h"
#import "AnalyticsViewController.h"
#import "WeekdayView.h"
#import "FSCalendar.h"
#import "SWTableViewCell.h"

@interface MainViewController : UIViewController <WorkoutViewControllerDelegate, LoginViewControllerDelegate, AnalyticsViewControllerDelegate, WorkoutSelectionViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance, SWTableViewCellDelegate, WeekdayViewDelegate, BTQRScannerViewControllerDelegate, SettingsViewControllerDelegate>

@property (nonatomic) NSManagedObjectContext *context;

@end
