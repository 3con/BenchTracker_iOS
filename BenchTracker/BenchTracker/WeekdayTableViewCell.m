//
//  WeekdayTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WeekdayTableViewCell.h"

@interface WeekdayTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *weekdayTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdaySubtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedView;

@end

@implementation WeekdayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.stackedView.layer.cornerRadius = 3;
    self.stackedView.clipsToBounds = YES;
}

- (void)loadDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E";
    self.weekdayTitleLabel.text = [formatter stringFromDate:date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    self.weekdaySubtitleLabel.text = [NSString stringWithFormat:@"%ld", components.day];
}

- (void)loadWithWorkouts:(NSArray <BTWorkout *> *)workouts {
    
}

#pragma mark - stackedView datasource

- (NSInteger)numberOfBarsForStackedBarView:(BTStackedBarView *)barView {
    return 0;
}

- (NSInteger)stackedBarView:(BTStackedBarView *)barView valueForBarAtIndex:(NSInteger)index {
    return 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
