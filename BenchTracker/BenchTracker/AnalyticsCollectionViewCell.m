//
//  AnalyticsCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsCollectionViewCell.h"

@implementation AnalyticsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
}

@end
