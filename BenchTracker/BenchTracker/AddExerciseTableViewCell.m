//
//  AddExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AddExerciseTableViewCell.h"
#import "BTExerciseType+CoreDataClass.h"

@interface AddExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *iterationLabel;

@end

@implementation AddExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellSelected = NO;
    self.iterationLabel.layer.cornerRadius = 10;
    self.iterationLabel.clipsToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (self.cellSelected) {
        self.backgroundColor = (highlighted) ? [self.color colorWithAlphaComponent:.85] :
                                               self.color;
    }
    else {
        self.backgroundColor = (highlighted) ? [UIColor BTTableViewSelectionColor] :
                                               [UIColor BTTableViewBackgroundColor];
    }
}

- (void)loadExerciseType:(BTExerciseType *)exerciseType {
    self.exerciseType = exerciseType;
    NSInteger count = [[NSKeyedUnarchiver unarchiveObjectWithData:exerciseType.iterations] count];
    self.iterationLabel.alpha = count > 0;
    if (count > 0) self.iterationLabel.text = [NSString stringWithFormat:@"%ld iteration%@",count,(count == 1) ? @"" : @"s"];
}

- (void)loadIteration:(NSString *)iteration {
    self.iteration = iteration;
    if (self.cellSelected && self.iteration && self.iteration.length > 0) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@", iteration, self.exerciseType.name]];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]
                    range:NSMakeRange(0, iteration.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]
                    range:NSMakeRange(iteration.length, str.length-iteration.length)];
        self.nameLabel.attributedText = str;
    }
    else {
        self.nameLabel.text = self.exerciseType.name;
        self.nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        self.backgroundColor = self.color;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.iterationLabel.backgroundColor = [UIColor whiteColor];
        self.iterationLabel.textColor = self.color;
        self.cellSelected = YES;
    }
    else {
        self.backgroundColor = [UIColor BTTableViewBackgroundColor];
        self.nameLabel.textColor = [UIColor BTBlackColor];
        self.iterationLabel.backgroundColor = [self.color colorWithAlphaComponent:1];
        self.iterationLabel.textColor = [UIColor whiteColor];
        self.cellSelected = NO;
        self.iteration = nil;
    }
    [self loadIteration:self.iteration];
}

@end
