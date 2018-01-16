//
//  AETableHeaderView.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/30/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AETableHeaderView;

@protocol AETableHeaderViewDelegate <NSObject>
- (void)headerView:(AETableHeaderView *)headerView didChangeExpanded:(BOOL)expanded;
@end

@interface AETableHeaderView : UIView

@property (nonatomic) id<AETableHeaderViewDelegate> delegate;
@property (nonatomic) NSInteger section;

@property (nonatomic) NSString *name;
@property (nonatomic) UIColor *color;
@property (nonatomic) BOOL expanded;

@end
