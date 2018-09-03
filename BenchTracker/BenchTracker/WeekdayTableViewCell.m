//
//  WeekdayTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WeekdayTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "WorkoutDetailsView.h"

@interface WeekdayTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet UILabel *weekdayTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdaySubtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterConstraint;

@property (weak, nonatomic) IBOutlet UIView *workoutDetailsContainerView;
@property (nonatomic) WorkoutDetailsView *workoutDetailsView;

@property (nonatomic) NSMutableArray <NSArray *> *tempSummary;

@end

@implementation WeekdayTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.weekdayTitleLabel.textColor = [UIColor BTTextPrimaryColor];
    self.weekdaySubtitleLabel.textColor = [UIColor BTTextPrimaryColor];
    self.nameLabel.textColor = [UIColor BTBlackColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.stackedView.layer.cornerRadius = 6;
    self.stackedView.clipsToBounds = YES;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    self.backgroundColor = (highlighted) ? [UIColor BTTableViewSelectionColor] :
                                           [UIColor BTTableViewBackgroundColor];
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self.stackedView reloadData];
}

- (void)setDate:(NSDate *)date {
    _date = date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E";
    self.weekdayTitleLabel.text = [formatter stringFromDate:date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date];
    self.weekdaySubtitleLabel.text = [NSString stringWithFormat:@"%ld", (long)components.day];
}

- (void)setWorkouts:(NSArray<BTWorkout *> *)workouts {
    _workouts = workouts;
    if (workouts.count == 0) {
        self.nameLabel.alpha = 0;
        self.stackedView.alpha = 0;
    }
    else {
        MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Trash"]
                                                  backgroundColor:[UIColor BTRedColor]];
        delButton.buttonWidth = 80;
        self.leftButtons = @[delButton];
        self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
        self.leftExpansion.buttonIndex = 0;
        self.leftExpansion.fillOnTrigger = NO;
        self.leftExpansion.threshold = 2.0;
        MGSwipeButton *temButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"TemplateAdd"]
                                                  backgroundColor:[UIColor BTButtonSecondaryColor]];
        temButton.buttonWidth = 80;
        self.rightButtons = @[temButton];
        self.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        self.rightExpansion.buttonIndex = 0;
        self.rightExpansion.fillOnTrigger = NO;
        self.rightExpansion.threshold = 2.0;
        if (workouts.count == 1)
            self.nameLabel.text = ([BTSettings sharedInstance].showSmartNames && workouts[0].smartName) ?
                workouts[0].smartNickname : workouts[0].name;
        else self.nameLabel.text = [NSString stringWithFormat:@"%ld workouts",(unsigned long)workouts.count];
        [self loadStackedViewWithWorkouts:workouts];
    }
    if (workouts.count == 1 && [BTSettings sharedInstance].showWorkoutDetails) {
        if (!self.workoutDetailsView) {
            self.contentCenterConstraint.constant = -11;
            self.workoutDetailsView = [[NSBundle mainBundle] loadNibNamed:@"WorkoutDetailsView" owner:self options:nil].firstObject;
            self.workoutDetailsView.frame = CGRectMake(0, 0, self.workoutDetailsContainerView.frame.size.width, 20);
            self.workoutDetailsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.workoutDetailsContainerView addSubview:self.workoutDetailsView];
        }
        [self.workoutDetailsView loadWithWorkout:workouts.firstObject];
    }
    else {
        if (self.workoutDetailsView) {
            [self.workoutDetailsView removeFromSuperview];
            self.workoutDetailsView = nil;
        }
        self.contentCenterConstraint.constant = 0;
    }
}

- (void)setToday:(BOOL)today {
    _today = today;
    self.weekdayContainerView.backgroundColor = (today) ? [UIColor BTTertiaryColor] : [UIColor BTPrimaryColor];
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
    [self.stackedView setNeedsLayout];
    [self.stackedView layoutIfNeeded];
    self.stackedView.dataSource = self;
    [self.stackedView reloadData];
}

- (bool)checkTemplateStatus {
    [self refreshButtons:YES];
    if (self.workouts.count == 0) return NO;
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Trash"] backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    if (![BTWorkoutTemplate templateExistsForWorkout:self.workouts.firstObject]) {
        MGSwipeButton *temButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"TemplateAdd"]
                                                  backgroundColor:[UIColor BTButtonSecondaryColor]];
        temButton.buttonWidth = 80;
        self.rightButtons = @[temButton];
    }
    else {
        MGSwipeButton *temButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"TemplateDelete"]
                                                  backgroundColor:[UIColor BTRedColor]];
        temButton.buttonWidth = 80;
        self.rightButtons = @[temButton];
    }
    return YES;
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

@end
