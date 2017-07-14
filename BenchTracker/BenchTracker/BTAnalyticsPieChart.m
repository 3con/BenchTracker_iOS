//
//  BTAnalyticsPieChart.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTAnalyticsPieChart.h"

@implementation BTAnalyticsPieChart

- (id)initWithFrame:(CGRect)frame items:(NSArray *)items {
    if (self = [super initWithFrame:frame items:items]) {
        self.tag = (items.count == 0) ? -1 : 0;
        [self loadLayout];
    }
    return self;
}

+ (NSArray *)pieDataForDictionary:(NSDictionary <NSString *, NSNumber *> *)data {
    NSMutableArray *items = [NSMutableArray array];
    float max = -MAXFLOAT;
    float min = MAXFLOAT;
    for (NSNumber *num in data.allValues) {
        float x = num.floatValue;
        if (x < min) min = x;
        if (x > max) max = x;
    }
    NSArray *orderedKeys = [data keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj2 compare:obj1];
    }];
    for (NSString *key in orderedKeys)
        [items addObject:[PNPieChartDataItem dataItemWithValue:data[key].floatValue
            color:[UIColor colorWithWhite:1 alpha:(max==min) ? .3 : (data[key].floatValue-min)/(max-min)*.4+.1] description:key]];
    return items;
}

#pragma mark - private mathods

- (void)loadLayout {
    self.backgroundColor = [UIColor clearColor];
    self.shouldHighlightSectorOnTouch = NO;
    self.showAbsoluteValues = YES;
    self.descriptionTextShadowColor = [UIColor clearColor];
    self.descriptionTextFont = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
