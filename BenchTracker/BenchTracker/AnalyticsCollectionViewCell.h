//
//  AnalyticsCollectionViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PNGenericChart;
@class BTAnalyticsTableView;

@interface AnalyticsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic) PNGenericChart *graphView;
@property (weak, nonatomic) IBOutlet BTAnalyticsTableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *seeMoreButton;
@end
