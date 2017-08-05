//
//  ADMuscleSplitTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADMuscleSplitTableViewCell.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTAnalyticsPieChart.h"

@interface ADMuscleSplitTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (nonatomic) BTAnalyticsPieChart *graphView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel1;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel3;
@property (weak, nonatomic) IBOutlet UILabel *subtitileLabel4;

@end

@implementation ADMuscleSplitTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.containerView.backgroundColor = [color colorWithAlphaComponent:.8];
}

- (void)loadWithDate:(NSDate *)date workouts:(NSArray <BTWorkout *> *)workouts weightSuffix:(NSString *)suffix {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d";
    self.titleLabel.text = [NSString stringWithFormat:@"Week of %@",[formatter stringFromDate:date]];
    NSMutableDictionary <NSString *, NSNumber *> *exerciseTypes = [NSMutableDictionary dictionary];
    long numExercises = 0;
    long numSets = 0;
    long volume = 0;
    for (BTWorkout *workout in workouts) {
        for (NSString *exerciseType in [workout.summary componentsSeparatedByString:@"#"]) {
            if (exerciseType.length < 2) break;
            NSArray <NSString *> *splt = [exerciseType componentsSeparatedByString:@" "];
            NSString *name = [exerciseType substringFromIndex:splt[0].length+1];
            if (!exerciseTypes[name]) exerciseTypes[name] = [NSNumber numberWithInt:splt[0].intValue];
            else exerciseTypes[name] = [NSNumber numberWithInt:exerciseTypes[name].intValue+splt[0].intValue];
        }
        numExercises += workout.numExercises;
        numSets += workout.numSets;
        volume += workout.volume;
    }
    self.subtitileLabel1.text = [NSString stringWithFormat:@"%ld workouts",(unsigned long)workouts.count];
    self.subtitileLabel2.text = [NSString stringWithFormat:@"%ld exercises",numExercises];
    self.subtitileLabel3.text = [NSString stringWithFormat:@"%ld sets",numSets];
    self.subtitileLabel4.text = [NSString stringWithFormat:@"%ldk %@",volume/1000,suffix];
    [self.graphView removeFromSuperview];
    self.graphView = [[BTAnalyticsPieChart alloc] initWithFrame:CGRectMake(0, 0, 150, 150)
                                                          items:[BTAnalyticsPieChart pieDataForDictionary:exerciseTypes]];
    [self.graphContainerView addSubview:self.graphView];
    [self.graphView strokeChart];
}

@end
