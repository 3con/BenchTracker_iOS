//
//  BTAnalyticsBarChart.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTAnalyticsBarChart.h"

@implementation BTAnalyticsBarChart

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadLayout];
    }
    return self;
}

- (void)setBarData:(NSDictionary <NSString *, NSNumber *> *)data {
    NSMutableArray *xData = [NSMutableArray array];
    NSMutableArray *yData = [NSMutableArray array];
    NSArray *orderedKeys = [data keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    for (int i = 0; i < 8; i++) {
        [xData addObject:orderedKeys[i]];
        [yData addObject:data[orderedKeys[i]]];
    }
    [self setXLabels:xData];
    [self setYValues:yData];
}

#pragma mark - private mathods

- (void)loadLayout {
    self.backgroundColor = [UIColor clearColor];
    self.labelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.xLabelWidth = 80;
    self.strokeColor = [UIColor whiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
