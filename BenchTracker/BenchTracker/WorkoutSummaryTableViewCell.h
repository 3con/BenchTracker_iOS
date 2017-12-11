//
//  WorkoutSummaryTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WorkoutMilestone.h"

@interface WorkoutSummaryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)loadWithMilestone:(WorkoutMilestone *)milestone;

@end
