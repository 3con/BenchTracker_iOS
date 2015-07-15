//
//  StepViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StepViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSMutableArray *arrUpperChest;
@property NSMutableArray *arrLowerChest;
@property NSMutableArray *arrArm;
@property NSMutableArray *arrShoulders;
@property NSMutableArray *arrLeg;

extern NSMutableArray *choices;
extern NSString *selectedStep;
extern NSIndexPath *path;

@end
