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
    self.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.titleLabel.textColor = [UIColor BTGrayColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.backgroundColor = (highlighted) ? [UIColor BTTableViewSelectionColor] :
                                           [UIColor BTTableViewBackgroundColor];
}

- (void)loadWithName:(NSString *)name {
    self.titleLabel.text = name;
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Trash"] backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    self.leftExpansion.buttonIndex = 0;
    self.leftExpansion.fillOnTrigger = NO;
    self.leftExpansion.threshold = 2.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
