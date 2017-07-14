//
//  IterationTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "IterationTableViewCell.h"

@interface IterationTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation IterationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.textColor = [UIColor BTBlackColor];
}

- (void)loadName:(NSString *)name iteration:(NSString *)iteration {
    if (iteration) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ %@",iteration,name]];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightBold]
                                              range:NSMakeRange(0, iteration.length)];
        [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular]
                                              range:NSMakeRange(iteration.length, str.length-iteration.length)];
        [str addAttribute:NSForegroundColorAttributeName value:[UIColor BTGrayColor]
                                              range:NSMakeRange(iteration.length, str.length-iteration.length)];
        self.nameLabel.attributedText = str;
    }
    else {
        self.nameLabel.text = [NSString stringWithFormat:@"%@ (Default)",name];
        self.nameLabel.textColor = [UIColor BTGrayColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
