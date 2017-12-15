//
//  UserStatView.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UserStatView.h"

@implementation UserStatView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 12.0;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.frame.size.height > 65) {
        self.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        self.statLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightSemibold];
    }
    else {
        self.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        self.statLabel.font = [UIFont systemFontOfSize:23 weight:UIFontWeightSemibold];
    }
}

@end
