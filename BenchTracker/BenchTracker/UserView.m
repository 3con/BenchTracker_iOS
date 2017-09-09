//
//  UserView.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UserView.h"
#import "BTUser+CoreDataClass.h"

@interface UserView ()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *mainLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *progressForegroundView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressWidthConstraint;

@property (nonatomic) CGFloat progress;

@end

@implementation UserView

- (void)loadUser:(BTUser *)user {
    self.progressBackgroundView.layer.cornerRadius = self.progressBackgroundView.frame.size.height/2.0;
    self.progressBackgroundView.clipsToBounds = YES;
    self.mainLabel.text = [NSString stringWithFormat:@"%ld",user.level];
    self.bottomLabel.text = [NSString stringWithFormat:@"%d xp",user.xp];
    self.progress = user.levelProgress;
}

- (void)animateIn {
    [self layoutIfNeeded];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:.75 animations:^{
        [self.progressBackgroundView removeConstraint:self.progressWidthConstraint];
        self.progressWidthConstraint = [NSLayoutConstraint constraintWithItem:self.progressForegroundView
                                                                    attribute:NSLayoutAttributeWidth
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.progressBackgroundView
                                                                    attribute:NSLayoutAttributeWidth
                                                                   multiplier:MIN(.95, MAX(.05, self.progress))
                                                                     constant:0];
        [self.progressBackgroundView addConstraint:self.progressWidthConstraint];
        [self layoutIfNeeded];
    }];
}

@end
