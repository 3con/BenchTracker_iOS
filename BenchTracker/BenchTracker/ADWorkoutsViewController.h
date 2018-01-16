//
//  ADWorkoutsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsDetailViewController.h"
#import "WorkoutViewController.h"
#import <CoreData/CoreData.h>

@interface ADWorkoutsViewController : AnalyticsDetailViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, WorkoutViewControllerDelegate>

@end
