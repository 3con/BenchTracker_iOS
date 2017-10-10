//
//  ExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"
#import "SetSummaryCollectionView.h"

@interface ExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *colorView1;
@property (weak, nonatomic) IBOutlet UIView *colorView2;
@property (weak, nonatomic) IBOutlet UIView *colorView3;

@property (weak, nonatomic) IBOutlet UIView *aboveSupersetView;
@property (weak, nonatomic) IBOutlet UIView *belowSupersetView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet SetSummaryCollectionView *collectionView;

@end

@implementation ExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundColor = [UIColor BTSecondaryColor];
    self.aboveSupersetView.backgroundColor = [UIColor BTSecondaryColor];
    self.belowSupersetView.backgroundColor = [UIColor BTSecondaryColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.containerView.layer.cornerRadius = 8;
    self.containerView.clipsToBounds = YES;
}

- (void)loadExercise:(BTExercise *)exercise {
    MGSwipeButton *delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"Trash"] backgroundColor:[UIColor BTRedColor]];
    delButton.buttonWidth = 80;
    self.leftButtons = @[delButton];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    if ([self.supersetMode isEqualToString:SUPERSET_NONE]) {
        self.aboveSupersetView.alpha = 0;
        self.belowSupersetView.alpha = 0;
    }
    else if ([self.supersetMode isEqualToString:SUPERSET_ABOVE]) self.aboveSupersetView.alpha = 0;
    else if ([self.supersetMode isEqualToString:SUPERSET_BELOW]) self.belowSupersetView.alpha = 0;
    self.exercise = exercise;
    if (exercise.iteration) self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",exercise.iteration,exercise.name];
    else                    self.nameLabel.text = exercise.name;
    self.categoryLabel.text = exercise.category;
    if (self.color) {
        self.colorView1.backgroundColor = self.color;
        self.colorView2.backgroundColor = self.color;
        self.colorView3.backgroundColor = self.color;
    }
    self.collectionView.enableOverlayLabel = YES;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.textColor = [UIColor BTSecondaryColor];
    self.collectionView.sets = [NSKeyedUnarchiver unarchiveObjectWithData:self.exercise.sets];
}

@end
