//
//  WorkoutSummaryTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutSummaryTableViewCell.h"
#import "WorkoutMilestone.h"

@implementation WorkoutSummaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.alpha = 0;
    self.titleImageView.alpha = 0;
    self.titleLabel.transform = CGAffineTransformMakeScale(0, 0);
    self.titleImageView.transform = CGAffineTransformMakeScale(0, 0);
}

- (void)loadWithMilestone:(WorkoutMilestone *)milestone {
    if (milestone) {
        self.titleLabel.text = milestone.title;
        switch (milestone.type) {
            case WorkoutMilestoneTypeOneRMExercise: self.titleImageView.image = [UIImage imageNamed:@"Exercise"]; break;
            case WorkoutMilestoneTypeVolumeExercise: self.titleImageView.image = [UIImage imageNamed:@"Weight"]; break;
            case WorkoutMilestoneTypeWorkout:     self.titleImageView.image = [UIImage imageNamed:@"Workout"]; break;
            case WorkoutMilestoneTypeNewExercise: self.titleImageView.image = [UIImage imageNamed:@"New"]; break;
            case WorkoutMilestoneTypeAchievement: self.titleImageView.image = [UIImage imageNamed:@"Badge"]; break;
            case WorkoutMilestoneTypeStreak:      self.titleImageView.image = [UIImage imageNamed:@"Streak"]; break;
        }
        self.titleImageView.image = [self.titleImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.titleImageView.tintColor = [UIColor whiteColor];
    }
    else {
        self.titleLabel.text = @"";
        self.titleImageView.image = nil;
    }
}

-(void)animateIn {
    [UIView animateWithDuration:.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.titleLabel.alpha = 1;
        self.titleImageView.alpha = 1;
        self.titleLabel.transform = CGAffineTransformIdentity;
        self.titleImageView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

@end
