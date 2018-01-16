//
//  ADWorkoutsTableViewCell.m
//  BenchTracker
//
//  Created by Student User on 1/14/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "ADWorkoutsTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"

@interface ADWorkoutsTableViewCell()

@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedBarView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic) NSMutableArray <NSArray *> *tempSummary;

@end

@implementation ADWorkoutsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.backgroundColor = (highlighted) ? [UIColor colorWithWhite:1 alpha:.15] :
                                           [UIColor clearColor];
}

- (void)setWorkout:(BTWorkout *)workout {
    _workout = workout;
    NSString *suffix = (self.type == QUERY_TYPE_VOLUME) ? [NSString stringWithFormat:@"k %@", self.weightSuffix] :
                       (self.type == QUERY_TYPE_DURATION) ? @" min" : @"";
    long long value = (self.type == QUERY_TYPE_VOLUME) ? self.workout.volume/1000 :
                      (self.type == QUERY_TYPE_DURATION) ? self.workout.duration/60 :
                      (self.type == QUERY_TYPE_NUMEXERCISES) ? self.workout.numExercises : self.workout.numSets;
    self.titleLabel.attributedText =
        [self attributedStringForDate:self.workout.date value:[NSString stringWithFormat:@"%lld%@",value,suffix]];
    [self loadStackedView];
}

#pragma mark - stackedBarView dataSource

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
    return [UIColor colorWithWhite:1 alpha:((arc4random()%100)/100.0)*.5];
}

#pragma mark - private helper methods

- (void)loadStackedView {
    self.tempSummary = [NSMutableArray array];
    if (self.workout.summary.length > 1) {
        NSArray *sArr = [self.workout.summary componentsSeparatedByString:@"#"];
        for (NSString *s in sArr) {
            NSString *sNum = [s componentsSeparatedByString:@" "].firstObject;
            [self.tempSummary addObject:@[[s substringFromIndex:sNum.length+1], [NSNumber numberWithInteger:sNum.integerValue]]];
        }
    }
    self.stackedBarView.dataSource = self;
    [self.stackedBarView reloadData];
}

- (NSAttributedString *)attributedStringForDate:(NSDate *)date value:(NSString *)value {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E, MMM d";
    NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:
                                      [NSString stringWithFormat:@"%@ %@", value, [formatter stringFromDate:date]]];
    [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightHeavy]} range:NSMakeRange(0, value.length)];
    return mAS;
}

@end
