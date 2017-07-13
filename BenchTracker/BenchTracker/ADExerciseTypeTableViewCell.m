//
//  ADExerciseTypeTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/12/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADExerciseTypeTableViewCell.h"

@interface ADExerciseTypeTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ADExerciseTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.badgeLabel.layer.cornerRadius = 7;
    self.badgeLabel.clipsToBounds = YES;
}

- (void)loadWithName:(NSString *)name num:(NSInteger)num color:(UIColor *)color {
    self.titleLabel.text = name;
    self.badgeLabel.alpha = MIN(1, num);
    self.badgeLabel.text = (num>10) ? @"10+" : [NSString stringWithFormat:@"%ld",num];
    self.badgeLabel.backgroundColor = color;
}

@end
