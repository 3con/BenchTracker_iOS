//
//  AddExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AddExerciseTableViewCell.h"
#import "BTExerciseType+CoreDataClass.h"

@interface AddExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *iterationLabel1;
@property (weak, nonatomic) IBOutlet UILabel *iterationLabel2;
@property (weak, nonatomic) IBOutlet UILabel *iterationLabel3;

@end

@implementation AddExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.cellSelected = NO;
}

- (void)loadExerciseType:(BTExerciseType *)exerciseType {
    self.exerciseType = exerciseType;
    NSArray *iterations = [NSKeyedUnarchiver unarchiveObjectWithData:exerciseType.iterations];
    self.iterationLabel1.text = iterations[0];
    self.iterationLabel2.text = (iterations.count > 1) ? iterations[1] : @"";
    self.iterationLabel3.text = (iterations.count > 2) ? iterations[2] : @"";
    if (iterations.count > 3) self.iterationLabel3.text = [self.iterationLabel3.text stringByAppendingString:@" ++"];
}

- (void)loadIteration:(NSString *)iteration {
    self.iteration = iteration;
    if (self.cellSelected && self.iteration && self.iteration.length > 0) {
        self.iterationLabel1.alpha = 0;
        self.iterationLabel2.alpha = 0;
        self.iterationLabel3.alpha = 0;
        self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",iteration,self.exerciseType.name];
    }
    else {
        self.iterationLabel1.alpha = 1;
        self.iterationLabel2.alpha = 1;
        self.iterationLabel3.alpha = 1;
        self.nameLabel.text = self.exerciseType.name;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (selected) {
        self.backgroundColor = self.color;
        self.nameLabel.textColor = [UIColor whiteColor];
        self.iterationLabel1.textColor = [UIColor whiteColor];
        self.iterationLabel2.textColor = [UIColor whiteColor];
        self.iterationLabel3.textColor = [UIColor whiteColor];
        self.cellSelected = YES;
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
        self.nameLabel.textColor = [UIColor blackColor];
        self.iterationLabel1.textColor = [UIColor blackColor];
        self.iterationLabel2.textColor = [UIColor blackColor];
        self.iterationLabel3.textColor = [UIColor blackColor];
        self.cellSelected = NO;
        self.iteration = nil;
    }
    [self loadIteration:self.iteration];
}

@end
