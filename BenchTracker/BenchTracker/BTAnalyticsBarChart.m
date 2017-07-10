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
        return [obj2 compare:obj1];
    }];
    for (int i = 0; i < 8; i++) {
        [xData addObject:orderedKeys[i]];
        [yData addObject:data[orderedKeys[i]]];
    }
    self.yMaxValue = data[orderedKeys[0]].intValue+1; //FIX: PNbarChart.m
                                                      //updateBar:
                                                         //bar = [[PNBar alloc] initWithFrame:CGRectMake(barXPosition, _chartMarginTop, barWidth, self.showLevelLine ? chartCavanHeight/2.0:chartCavanHeight)];
                                                      //__addYCoordinateLabelsValues:
                                                         //label.frame = (CGRect){0, sectionHeight * i + _chartMarginTop - kYLabelHeight/2.0 , _yChartLabelWidth, kYLabelHeight};
    self.yLabelSum = MIN(5, data[orderedKeys[0]].intValue+1);
    [self setXLabels:xData];
    [self setYValues:yData];
}

#pragma mark - private mathods

- (void)loadLayout {
    self.backgroundColor = [UIColor clearColor];
    self.labelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.xLabelWidth = 20;
    self.barBackgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    self.strokeColor = [UIColor whiteColor];
    self.barWidth = 20;
    self.barRadius = 6;
    self.labelTextColor = [UIColor whiteColor];
    self.rotateForXAxisText = YES;
    self.chartMarginBottom = 32;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
