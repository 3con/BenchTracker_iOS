//
//  BTCalendarCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTCalendarCell.h"
#import "BTWorkout+CoreDataClass.h"

@interface BTCalendarCell ()

@property (nonatomic) BTStackedBarView *stackedView;

@property (nonatomic) NSMutableArray *tempSummary;

@end

@implementation BTCalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.stackedView = [[BTStackedBarView alloc] initWithFrame:CGRectMake(0, 0, MIN(60, frame.size.width-10), 20)];
        self.stackedView.layer.cornerRadius = 5;
        self.stackedView.clipsToBounds = YES;
        [self.contentView insertSubview:self.stackedView belowSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.textColor = [UIColor BTLightGrayColor];
    self.titleLabel.frame = self.contentView.bounds;
    self.titleLabel.center = CGPointMake(self.contentView.bounds.size.width/2.0, self.contentView.bounds.size.height/2.0-12);
    self.stackedView.center = CGPointMake(self.contentView.bounds.size.width/2.0, self.contentView.bounds.size.height/2.0+10);
}

- (void)loadWithWorkouts:(NSArray <BTWorkout *> *)workouts {
    BOOL hasWorkouts = (workouts && workouts.count > 0);
    self.stackedView.alpha = hasWorkouts;
    if (hasWorkouts) [self loadStackedViewWithWorkouts:workouts];
}

- (void)loadStackedViewWithWorkouts:(NSArray <BTWorkout *> *)workouts {
    self.tempSummary = [NSMutableArray array];
    for (BTWorkout *workout in workouts) {
        if (workout.summary.length > 1) {
            NSArray *sArr = [workout.summary componentsSeparatedByString:@"#"];
            for (NSString *s in sArr) {
                NSString *sNum = [s componentsSeparatedByString:@" "].firstObject;
                [self.tempSummary addObject:@[[s substringFromIndex:sNum.length+1], [NSNumber numberWithInteger:sNum.integerValue]]];
            }
        }
    }
    [self.stackedView setNeedsLayout];
    [self.stackedView layoutIfNeeded];
    self.stackedView.dataSource = self;
    [self.stackedView reloadData];
}

#pragma mark - stackedView dataSource

- (NSInteger)numberOfBarsForStackedBarView:(BTStackedBarView *)barView {
    return self.tempSummary.count;
}

- (NSInteger)stackedBarView:(BTStackedBarView *)barView valueForBarAtIndex:(NSInteger)index {
    return [self.tempSummary[index][1] integerValue];
}

- (UIColor *)stackedBarView:(BTStackedBarView *)barView colorForBarAtIndex:(NSInteger)index {
    return self.exerciseTypeColors[self.tempSummary[index][0]];
}

//Old implimentation: color for before and after user dates
//
//if ([date compare:self.calendarView.maximumDate] == NSOrderedDescending ||
//    [date compare:self.calendarView.minimumDate] == NSOrderedAscending) return [UIColor whiteColor];
//else if ([date compare:[NSDate date]] == NSOrderedDescending ||
//         [date compare:[self.firstDay dateByAddingTimeInterval:-86400]] == NSOrderedAscending) return [UIColor BTLightGrayColor];
//else if ([BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0)
//return [UIColor whiteColor];
//return [UIColor BTLightGrayColor];

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
