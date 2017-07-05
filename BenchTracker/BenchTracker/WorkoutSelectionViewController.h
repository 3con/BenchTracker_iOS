//
//  WorkoutSelectionViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SWTableViewCell.h"

@class BTWorkoutManager;

@interface WorkoutSelectionViewController : UIViewController <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, SWTableViewCellDelegate>

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTWorkoutManager *workoutManager;

@property (nonatomic) CGPoint originPoint;
@property (nonatomic) NSDate *date;

@end
