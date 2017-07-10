//
//  BTAnalyticsLineChart.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTAnalyticsLineChart.h"
#import "PNChart.h"

@implementation BTAnalyticsLineChart

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadLayout];
    }
    return self;
}

- (void)setXAxisData:(NSArray <NSString *> *)data {
    [self setXLabels:data]; //FIX in PNLineChart.h -> setXLabel:withWidth: NSInteger x = (index * _xLabelWidth + _chartMarginLeft);
}

- (void)setYAxisData:(NSArray <NSNumber *> *)data {
    float max = -MAXFLOAT;
    float min = MAXFLOAT;
    for (NSNumber *num in data) {
        float x = num.floatValue;
        if (x < min) min = x;
        if (x > max) max = x;
    }
    float diff = max-min;
    int scaleFactor = 1;
    while (diff > 1000) {
        diff = diff/10;
        scaleFactor = scaleFactor*10;
    }
    int interval = 0;
    if (diff <= 10) interval = 2;
    else if (diff <= 50) interval = 10;
    else if (diff <= 150) interval = 25;
    else if (diff <= 250) interval = 50;
    else if (diff <= 600) interval = 100;
    else interval = 250;
    interval = interval*scaleFactor;
    self.yFixedValueMin = MAX(0, ((int)min)/interval*interval-interval);
    self.yFixedValueMax = MAX(10, ((int)max)/interval*interval+interval);
    self.yLabelNum = (self.yFixedValueMax-self.yFixedValueMin)/interval;
    PNLineChartData *yData = [PNLineChartData new];
    yData.color = [UIColor whiteColor];
    yData.lineWidth = 5;
    yData.itemCount = data.count;
    yData.getData = ^(NSUInteger index) { return [PNLineChartDataItem dataItemWithY:[data[index] floatValue]]; };
    self.chartData = @[yData];
}

#pragma mark - private mathods

- (void)loadLayout {
    self.showSmoothLines = YES; //FIX in PNLineChart.h: chartLine.fillColor = [[UIColor clearColor] CGColor];
    self.backgroundColor = [UIColor clearColor];
    self.yLabelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.yLabelColor = [UIColor whiteColor];
    self.xLabelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.xLabelColor = [UIColor whiteColor];
    self.xLabelWidth = 80;
    self.thousandsSeparator = YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
