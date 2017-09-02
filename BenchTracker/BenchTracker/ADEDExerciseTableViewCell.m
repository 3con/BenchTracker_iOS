//
//  ADEDExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADEDExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "SetSummaryCollectionView.h"

@interface ADEDExerciseTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet SetSummaryCollectionView *collectionView;

@end

@implementation ADEDExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
}

- (void)loadExercise:(BTExercise *)exercise withWeightSuffix:(NSString *)suffix {
    NSString *s;
    if ([exercise.style isEqualToString:STYLE_REPSWEIGHT])      s = [NSString stringWithFormat:@"1RM: %lld %@",exercise.oneRM, suffix];
    else if ([exercise.style isEqualToString:STYLE_REPS])       s = [NSString stringWithFormat:@"Max: %lld reps",exercise.oneRM];
    else if ([exercise.style isEqualToString:STYLE_TIMEWEIGHT]) s = [NSString stringWithFormat:@"Max: %lld %@",exercise.oneRM, suffix];
    else if ([exercise.style isEqualToString:STYLE_TIME])       s = [NSString stringWithFormat:@"Max: %lld secs",exercise.oneRM];
    else                                                        s = @"Max: N/A";
    self.badgeLabel.text = s;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d ''yy";
    self.dateLabel.text = [formatter stringFromDate:exercise.workout.date];
    if (exercise.iteration && ![exercise.iteration isEqualToString:@"(null)"])
         self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",exercise.iteration,exercise.name];
    else self.titleLabel.text = exercise.name;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.textColor = self.color;
    self.collectionView.sets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
}

@end
