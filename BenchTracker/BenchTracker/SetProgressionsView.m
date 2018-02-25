//
//  SetProgressionsView.m
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "SetProgressionsView.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTAnalyticsLineChart.h"

@interface SetProgressionsView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noInstancesLabel;
@property (nonatomic) BTAnalyticsLineChart *lineChart;

@property NSArray<NSArray<NSNumber *> *> *data;

@end

@implementation SetProgressionsView

- (void)loadWithExerciseType:(BTExerciseType *)exerciseType iteration:(NSString *)iteration {
    if (!self.lineChart) {
        self.lineChart = [[BTAnalyticsLineChart alloc] initWithFrame:CGRectMake(5, 10, (MIN(500,self.frame.size.width))+10, 198)];
        self.lineChart.yAxisSpaceTop = 2;
        [self addSubview:self.lineChart];
    }
    self.data = [exerciseType recentSetProgressionsForIteration:iteration];
    [self.lineChart setYAxisMultiData:self.data];
    int64_t maxCount = 0;
    for (NSArray *a in self.data)
        maxCount = MAX(maxCount, a.count);
    NSMutableArray *xData = @[].mutableCopy;
    for (int i = 0; i < maxCount; i++)
        [xData addObject:[NSString stringWithFormat:@"%d",i+1]];
    [self.lineChart setXAxisData:xData];
    self.noInstancesLabel.alpha = xData.count == 0;
    self.lineChart.alpha = xData.count > 0;
}

- (void)strokeChart {
    [self.lineChart strokeChart];
}

@end
