//
//  BTStackedBarView.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTStackedBarView;

@protocol BTStackedBarViewDataSource <NSObject>
@required
- (NSInteger)numberOfBarsForStackedBarView:(BTStackedBarView *)barView;
- (NSInteger)stackedBarView:(BTStackedBarView *)barView valueForBarAtIndex:(NSInteger)index;
@optional
- (NSString *)stackedBarView:(BTStackedBarView *)barView nameForBarAtIndex:(NSInteger)index;
- (UIColor *)stackedBarView:(BTStackedBarView *)barView colorForBarAtIndex:(NSInteger)index;
@end

@interface BTStackedBarView : UIView

@property (nonatomic) id<BTStackedBarViewDataSource> dataSource;

- (void)reloadData;

@end
