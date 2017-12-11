//
//  WorkoutSummaryTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutSummaryTableViewCell.h"

@implementation WorkoutSummaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
}

- (void)loadWithMilestone:(WorkoutMilestone *)milestone {
    if (milestone) {
        self.titleLabel.text = milestone.title;
    }
    else {
        self.titleLabel.text = @"";
        self.titleImageView.image = nil;
    }
}

@end
