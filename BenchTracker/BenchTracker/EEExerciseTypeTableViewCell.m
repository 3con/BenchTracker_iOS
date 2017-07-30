//
//  EEExerciseTypeTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EEExerciseTypeTableViewCell.h"

@interface EEExerciseTypeTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation EEExerciseTypeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.textColor = [UIColor BTGrayColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSArray *)leftButtons {
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[UIColor BTRedColor] title:@"Delete"];
    return rightUtilityButtons;
}

- (void)loadWithName:(NSString *)name {
    self.titleLabel.text = name;
    self.leftUtilityButtons = [self leftButtons];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
