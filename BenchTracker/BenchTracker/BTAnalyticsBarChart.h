//
//  BTAnalyticsBarChart.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <PNChart/PNChart.h>

@interface BTAnalyticsBarChart : PNBarChart

- (id)initWithFrame:(CGRect)frame;

- (void)setBarData:(NSDictionary <NSString *, NSNumber *> *)data;

@end
