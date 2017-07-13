//
//  BTAnalyticsLineChart.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <PNChart/PNChart.h>

@interface BTAnalyticsLineChart : PNLineChart

@property (nonatomic) int yAxisSpaceTop;

- (id)initWithFrame:(CGRect)frame;

- (void)setXAxisData:(NSArray <NSString *> *)data;

- (void)setYAxisData:(NSArray <NSNumber *> *)data;

@end
