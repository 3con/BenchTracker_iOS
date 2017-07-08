//
//  AnalyticsCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsCollectionViewCell.h"
#import "PNChart.h"

@interface AnalyticsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;

@end

@implementation AnalyticsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.cornerRadius = 12;
    self.clipsToBounds = YES;
    self.seeMoreButton.layer.cornerRadius = 12;
    self.seeMoreButton.clipsToBounds = YES;
}

- (void)setGraphView:(PNGenericChart *)graphView {
    _graphView = graphView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.graphView) {
        [self.graphContainerView addSubview:self.graphView];
        self.graphView.frame = CGRectMake(0, 10, self.graphContainerView.frame.size.width, self.graphContainerView.frame.size.height-20);
    }
}

- (IBAction)seeMoreButtonPressed:(UIButton *)sender {
    
}

@end
