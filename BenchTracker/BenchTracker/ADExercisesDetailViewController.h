//
//  ADExercisesDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsDetailViewController.h"
#import "IterationSelectionViewController.h"
#import <CoreData/CoreData.h>

@interface ADExercisesDetailViewController : AnalyticsDetailViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, IterationSelectionViewControllerDelegate>

@end
