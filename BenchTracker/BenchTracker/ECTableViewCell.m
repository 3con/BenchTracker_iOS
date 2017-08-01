//
//  ECTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ECTableViewCell.h"
#import "BT1RMCalculator.h"

@implementation ECTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)loadWithWeight:(NSInteger)weight length:(NSInteger)length {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    for (int i = 0; i < length; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(80*i, 5, 80, 30)];
        label.textColor = [UIColor BTBlackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        label.text = [NSString stringWithFormat:@"%d",[BT1RMCalculator equivilentForReps:i+2 weight:weight]];
        [self.scrollView addSubview:label];
    }
    self.scrollView.contentSize = CGSizeMake(80*length, 39);
}

@end
