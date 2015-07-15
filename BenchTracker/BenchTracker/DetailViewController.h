//
//  DetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/5/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"

@interface DetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void) setDetailItem:(Workout *)detailItem;

@end

