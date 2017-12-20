//
//  LeaderboardTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "LeaderboardTableViewCell.h"

@interface LeaderboardTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;
@end

@implementation LeaderboardTableViewCell

- (void)setRank:(NSInteger)rank {
    self.rankLabel.text = [NSString stringWithFormat:@"%ld.",rank];
    self.rankLabel.font = [UIFont systemFontOfSize:(rank < 100) ? 19 : 14 weight:UIFontWeightSemibold];
    _rank = rank;
}

- (void)setIsSelf:(BOOL)isSelf {
    self.titleLabel.font = [UIFont systemFontOfSize:self.titleLabel.font.pointSize weight:(isSelf) ? UIFontWeightBold : UIFontWeightMedium];
    self.titleLabel.textColor = (isSelf) ? [UIColor BTBlackColor] : [UIColor BTGrayColor];
    _isSelf = isSelf;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.rankLabel.textColor = [UIColor BTGrayColor];
    self.titleLabel.textColor = [UIColor BTGrayColor];
    self.statLabel.textColor = [UIColor BTLightGrayColor];
}

@end
