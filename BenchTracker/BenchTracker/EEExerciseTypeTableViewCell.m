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

- (void)loadWithName:(NSString *)name {
    self.titleLabel.text = name;
    self.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor BTRedColor]]];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    self.leftExpansion.buttonIndex = 0;
    self.leftExpansion.fillOnTrigger = NO;
    self.leftExpansion.threshold = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
