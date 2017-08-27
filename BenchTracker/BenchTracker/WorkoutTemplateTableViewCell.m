//
//  WorkoutTemplateTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/26/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutTemplateTableViewCell.h"

@interface WorkoutTemplateTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedBarView;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel1;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel2;

@end

@implementation WorkoutTemplateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.textColor = [UIColor BTBlackColor];
    self.detailLabel1.textColor = [UIColor BTGrayColor];
    self.detailLabel2.textColor = [UIColor BTGrayColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.stackedBarView.layer.cornerRadius = 5;
    self.stackedBarView.clipsToBounds = YES;
    self.stackedBarView.dataSource = self;
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    self.leftExpansion.buttonIndex = 0;
    self.leftExpansion.fillOnTrigger = NO;
    self.leftExpansion.threshold = 2.0;
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self.stackedBarView reloadData];
}

#pragma mark - stackedBar dataSource

- (NSInteger)numberOfBarsForStackedBarView:(BTStackedBarView *)barView {
    return 3;
}

- (NSInteger)stackedBarView:(BTStackedBarView *)barView valueForBarAtIndex:(NSInteger)index {
    return 1;
}

- (NSString *)stackedBarView:(BTStackedBarView *)barView nameForBarAtIndex:(NSInteger)index {
    return @"test";
}

@end
