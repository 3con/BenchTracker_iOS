//
//  ADExercisesDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsDetailViewController.h"
#import "IterationSelectionViewController.h"
#import "WorkoutViewController.h"
#import <CoreData/CoreData.h>

@interface ADExercisesDetailViewController : AnalyticsDetailViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, IterationSelectionViewControllerDelegate, WorkoutViewControllerDelegate>

@property (nonatomic) NSString *iteration;

@end
