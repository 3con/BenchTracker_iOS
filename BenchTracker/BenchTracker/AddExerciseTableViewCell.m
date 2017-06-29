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
    
}

- (void)loadExerciseType:(BTExerciseType *)exerciseType {
    self.exerciseType = exerciseType;
    self.nameLabel.text = exerciseType.name;
    NSArray *iterations = [NSKeyedUnarchiver unarchiveObjectWithData:exerciseType.iterations];
    self.iterationLabel1.text = iterations[0];
    self.iterationLabel2.text = (iterations.count > 1) ? iterations[1] : @"";
    self.iterationLabel3.text = (iterations.count > 2) ? iterations[2] : @"";
    if (iterations.count > 3) self.iterationLabel3.text = [self.iterationLabel3.text stringByAppendingString:@" ++"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
