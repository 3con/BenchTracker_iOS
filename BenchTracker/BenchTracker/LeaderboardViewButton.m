//
//  LeaderboardViewButton.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/15/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "LeaderboardViewButton.h"

@implementation LeaderboardViewButton

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.layer.cornerRadius = 16;
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor BTVibrantColors][1];
    }
    return self;
}

@end
