//
//  UserStatView.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UserStatView.h"

@implementation UserStatView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 12.0;
        self.clipsToBounds = YES;
    }
    return self;
}

@end
