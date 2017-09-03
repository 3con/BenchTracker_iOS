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
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50*i+2.5, 2.5, 45, 30)];
        label.layer.cornerRadius = 12.0;
        label.clipsToBounds = YES;
        if (i == self.selectedSection) {
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor BTSecondaryColor];
        }
        else {
            label.textColor = [UIColor BTGrayColor];
            label.backgroundColor = [UIColor whiteColor];
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        label.text = [NSString stringWithFormat:@"%d",[BT1RMCalculator equivilentForReps:i+2 weight:weight]];
        [self.scrollView addSubview:label];
    }
    self.scrollView.contentSize = CGSizeMake(50*length, 34);
}

@end
