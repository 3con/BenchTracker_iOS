//
//  ADMuscleSplitTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADMuscleSplitTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"

@interface ADMuscleSplitTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UIView *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel1;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel3;

@end

@implementation ADMuscleSplitTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.containerView.backgroundColor = [color colorWithAlphaComponent:.8];
}

- (void)loadWithDate:(NSDate *)date workouts:(NSArray <BTWorkout *> *)workouts {
    
}

@end
