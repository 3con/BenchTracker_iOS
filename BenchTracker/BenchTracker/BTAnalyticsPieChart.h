//
//  BTAnalyticsPieChart.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <PNChart/PNChart.h>

@interface BTAnalyticsPieChart : PNPieChart

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items;

+ (NSArray *)pieDataForDictionary:(NSDictionary <NSString *, NSNumber *> *)data;

@end
