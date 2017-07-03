//
//  WeekdayTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WeekdayTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"

@interface WeekdayTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet UILabel *weekdayTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdaySubtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedView;

@property (nonatomic) NSMutableArray <NSArray *> *tempSummary;

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
    if (workouts.count == 0) {
        self.nameLabel.alpha = 0;
        self.stackedView.alpha = 0;
    }
    else {
        if (workouts.count == 1) self.nameLabel.text = workouts[0].name;
        else self.nameLabel.text = [NSString stringWithFormat:@"%ld workouts",workouts.count];
        [self loadStackedViewWithWorkouts:workouts];
    }
}

- (void)setToday:(BOOL)today {
    _today = today;
    if (today) self.weekdayContainerView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:120/255.0 alpha:1];
}

- (void)loadStackedViewWithWorkouts:(NSArray <BTWorkout *> *)workouts {
    for (BTWorkout *workout in workouts) {
        if (workout.summary.length > 1) {
            if (!self.tempSummary) self.tempSummary = [NSMutableArray array];
            NSArray *sArr = [workout.summary componentsSeparatedByString:@"#"];
            for (NSString *s in sArr) {
                NSString *sNum = [s componentsSeparatedByString:@" "].firstObject;
                [self.tempSummary addObject:@[[s substringFromIndex:sNum.length+1], [NSNumber numberWithInteger:sNum.integerValue]]];
            }
        }
    }
    self.stackedView.dataSource = self;
    [self.stackedView reloadData];
}

#pragma mark - stackedView datasource

- (NSInteger)numberOfBarsForStackedBarView:(BTStackedBarView *)barView {
    return self.tempSummary.count;
}

- (NSInteger)stackedBarView:(BTStackedBarView *)barView valueForBarAtIndex:(NSInteger)index {
    return [self.tempSummary[index][1] integerValue];
}

- (NSString *)stackedBarView:(BTStackedBarView *)barView nameForBarAtIndex:(NSInteger)index {
    return self.tempSummary[index][0];
}

- (UIColor *)stackedBarView:(BTStackedBarView *)barView colorForBarAtIndex:(NSInteger)index {
    return self.exerciseTypeColors[self.tempSummary[index][0]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
