//
//  WorkoutTemplateTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/26/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutTemplateTableViewCell.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTExerciseTemplate+CoreDataClass.h"

@interface WorkoutTemplateTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet BTStackedBarView *stackedBarView;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel1;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel2;

@property (nonatomic) BTWorkoutTemplate *template;
@property (nonatomic) NSMutableArray <NSArray *> *tempSummary;

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
}

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
    [self.stackedBarView reloadData];
}

- (void)loadWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate {
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Trash"] backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    self.leftExpansion.buttonIndex = 0;
    self.leftExpansion.fillOnTrigger = NO;
    self.leftExpansion.threshold = 2.0;
    self.template = workoutTemplate;
    self.nameLabel.text = workoutTemplate.name;
    self.stackedBarView.dataSource = self;
    [self loadStackedView];
    NSMutableAttributedString *leftStr = [[NSMutableAttributedString alloc] init];
    NSMutableAttributedString *rightStr = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < workoutTemplate.exercises.count; i++) {
        BTExerciseTemplate *exercise = workoutTemplate.exercises[i];
        UIColor *color = self.exerciseTypeColors[exercise.category];
        NSMutableAttributedString *tStr = (i <= (workoutTemplate.exercises.count+1)/2-1) ? leftStr : rightStr;
        [tStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n● "
                                                                     attributes:@{NSForegroundColorAttributeName: color}]];
        [tStr appendAttributedString:[[NSAttributedString alloc] initWithString:exercise.name]];
    }
    self.detailLabel1.attributedText = (leftStr.length > 2) ? [leftStr attributedSubstringFromRange:NSMakeRange(1, leftStr.length-1)] : nil;
    self.detailLabel2.attributedText = (rightStr.length > 2) ? [rightStr attributedSubstringFromRange:NSMakeRange(1, rightStr.length-1)] : nil;
}

- (void)loadStackedView {
    self.tempSummary = [NSMutableArray array];
    if (self.template.summary.length > 1) {
        NSArray *sArr = [self.template.summary componentsSeparatedByString:@"#"];
        for (NSString *s in sArr) {
            NSString *sNum = [s componentsSeparatedByString:@" "].firstObject;
            [self.tempSummary addObject:@[[s substringFromIndex:sNum.length+1], [NSNumber numberWithInteger:sNum.integerValue]]];
        }
    }
    self.stackedBarView.dataSource = self;
    [self.stackedBarView reloadData];
}

+ (CGFloat)heightForWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate {
    NSInteger numRows = (workoutTemplate.exercises.count+1)/2;
    return 71+numRows*15.8;
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
