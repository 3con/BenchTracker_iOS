//
//  SetsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/7/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Step.h"

@interface SetsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewL;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerViewR;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (void) setDetailItem:(Step *)detailItem;

@end
