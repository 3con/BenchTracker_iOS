//
//  AnalyticsCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsCollectionViewCell.h"
#import "PNChart.h"
#import "BTAnalyticsTableView.h"

@interface AnalyticsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@end

@implementation AnalyticsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
    self.graphContainerView.layer.masksToBounds = NO;
    self.graphContainerView.layer.cornerRadius = 8;
    self.graphContainerView.clipsToBounds = YES;
    self.seeMoreButton.layer.cornerRadius = 12;
    self.seeMoreButton.clipsToBounds = YES;
    self.tableView.layer.cornerRadius = 12;
    self.tableView.clipsToBounds = YES;
}

- (void)setGraphView:(PNGenericChart *)graphView {
    _graphView = graphView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.graphView) {
        [self.graphContainerView addSubview:self.graphView];
        [self.graphContainerView sizeToFit];
    }
}

- (IBAction)seeMoreButtonPressed:(UIButton *)sender {
    
}

@end
