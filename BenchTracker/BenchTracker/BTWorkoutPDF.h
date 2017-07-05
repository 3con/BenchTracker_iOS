//
//  BTWorkoutPDF.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTWorkout;

@interface BTWorkoutPDF : UIView <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *metadataLabel1;
@property (weak, nonatomic) IBOutlet UILabel *metadataLabel2;

- (void)loadWorkout:(BTWorkout *)workout;

@end
