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
    if (data.count == 0) {
        self.tag = -1;
        return;
    }
    else self.tag = 0;
    NSMutableArray *xData = [NSMutableArray array];
    NSMutableArray *yData = [NSMutableArray array];
    NSArray *orderedKeys = [data keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    for (int i = 0; i < MIN(data.count, self.frame.size.width/38.0); i++) {
        [xData addObject:orderedKeys[i]];
        [yData addObject:data[orderedKeys[i]]];
    }
    if (orderedKeys.count > 0) {
        int max = data[orderedKeys[0]].intValue;
        int interval = max/5+1;
        self.yMaxValue = max/interval*interval+interval;
        self.yLabelSum = max/interval+1;
        [self setXLabels:xData];
        [self setYValues:yData];
    //COCOAPODS PNCHART FIX in PNBarChart.m -> updateBar:
        //bar = [[PNBar alloc] initWithFrame:CGRectMake(barXPosition, _chartMarginTop, barWidth, self.showLevelLine ? chartCavanHeight/2.0:chartCavanHeight)];
    //COCOAPODS PNCHART FIX in PNBarChart.m -> __addYCoordinateLabelsValues:
        //label.frame = (CGRect){0, sectionHeight * i + _chartMarginTop - kYLabelHeight/2.0 , _yChartLabelWidth, kYLabelHeight};
    //COCOAPODS PNCHART FIX in PNBarChart.m -> setXLabels:
        //PNChartLabel *label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, 0, 42, kXLabelHeight)];
        //labelXPosition = (index *  _xLabelWidth + _chartMarginLeft + _xLabelWidth / 2.0);
        //label.center = CGPointMake(labelXPosition, self.frame.size.height - kXLabelHeight - _chartMarginTop + 20 + _labelMarginTop);
    //COCOAPODS PNCHART FIX in PNBarChart.m -> ProcessYMaxValue:
        //REMOVE: if (_yLabelSum==4) { _yLabelSum = yAxisValues.count; (_yLabelSum % 2 == 0) ? _yLabelSum : _yLabelSum++; }
    }
}

#pragma mark - private mathods

- (void)loadLayout {
    self.backgroundColor = [UIColor clearColor];
    self.labelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.xLabelWidth = 100;
    self.barBackgroundColor = [UIColor colorWithWhite:1 alpha:.1];
    self.strokeColor = [UIColor whiteColor];
    self.barWidth = 20;
    self.barRadius = 6;
    self.labelTextColor = [UIColor whiteColor];
    self.rotateForXAxisText = YES;
    self.chartMarginBottom = 32;
    self.isShowNumbers = NO;
}

@end
