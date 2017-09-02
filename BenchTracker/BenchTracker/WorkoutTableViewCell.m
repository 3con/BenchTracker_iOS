//
//  WorkoutTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/30/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTWorkoutTemplate+CoreDataClass.h"

@interface WorkoutTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedView;

@property (nonatomic) BTWorkout *workout;

@property (nonatomic) NSMutableArray <NSArray *> *tempSummary;

@end

@implementation WorkoutTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.textColor = [UIColor BTBlackColor];
    self.dateLabel.textColor = [UIColor BTGrayColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.stackedView.layer.cornerRadius = 5;
    self.stackedView.clipsToBounds = YES;
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self.stackedView reloadData];
}

- (void)loadWorkout:(BTWorkout *)workout {
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor BTRedColor]];
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
    self.workout = workout;
    self.nameLabel.text = workout.name;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMMM d"];
    self.dateLabel.text = [formatter stringFromDate:workout.date];
    [self loadStackedView];
}

- (void)loadStackedView {
    self.tempSummary = [NSMutableArray array];
    if (self.workout.summary.length > 1) {
        NSArray *sArr = [self.workout.summary componentsSeparatedByString:@"#"];
        for (NSString *s in sArr) {
            NSString *sNum = [s componentsSeparatedByString:@" "].firstObject;
            [self.tempSummary addObject:@[[s substringFromIndex:sNum.length+1], [NSNumber numberWithInteger:sNum.integerValue]]];
        }
    }
    self.stackedView.dataSource = self;
    [self.stackedView reloadData];
}

+ (CGFloat)heightForWorkoutCell {
    return 60.0;
}

- (void)checkTemplateStatus {
    [self refreshButtons:YES];
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    if (![BTWorkoutTemplate templateExistsForWorkout:self.workout]) {
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
