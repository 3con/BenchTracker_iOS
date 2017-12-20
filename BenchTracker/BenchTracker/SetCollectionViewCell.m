//
//  SetCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SetCollectionViewCell.h"
#import "BT1RMCalculator.h"

@interface SetCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation SetCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.display1RM = NO;
    self.containerView.backgroundColor = [UIColor BTSecondaryColor];
    self.topLabel.textColor = [UIColor BTTextPrimaryColor];
    self.bottomLabel.textColor = [UIColor BTTextPrimaryColor];
    self.deleteButton.backgroundColor = [UIColor BTRedColor];
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    self.deleteButton.layer.cornerRadius = 7.5;
    self.deleteButton.clipsToBounds = YES;
}

- (void)loadSetWithString:(NSString *)set weightSuffix:(NSString *)suffix {
    if (self.color) self.containerView.backgroundColor = self.color;
    self.containerView.frame = CGRectMake(0, 0, 70, 45);
    NSArray <NSString *> *strings = [set componentsSeparatedByString:@" "];
    if ([strings[0] isEqualToString:@"~"]) { //custom
        self.topLabel.text = @"Custom";
        self.bottomLabel.text = [set substringFromIndex:2];
    }
    else if ([strings[0] containsString:@"s"]) {
        if(strings.count == 3) { //timeWeight
            self.topLabel.text = [NSString stringWithFormat:@"%@ %@",strings[2], suffix];
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ secs",strings[1]];
        }
        else { //time
            self.topLabel.text = @"";
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ secs",strings[1]];
        }
    }
    else {
        if(strings.count == 2) { //repsWeight
            if (self.display1RM) {
                self.topLabel.text = [NSString stringWithFormat:@"%@x%@",strings[0], strings[1]];
                self.bottomLabel.text = [NSString stringWithFormat:@"%d %@",
                     [BT1RMCalculator equivilentForReps:strings[0].intValue weight:strings[1].floatValue], suffix];
            }
            else {
                self.topLabel.text = [NSString stringWithFormat:@"%@ reps",strings[0]];
                self.bottomLabel.text = [NSString stringWithFormat:@"%@ %@",strings[1], suffix];
            }
        }
        else { //reps
            self.topLabel.text = @"";
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ reps",set];
        }
    }
}

- (void)performDeleteAnimationWithDuration: (float)duration {
    [UIView animateWithDuration:duration animations:^{
        self.containerView.frame = CGRectMake(self.deleteButton.center.x-2.5, self.deleteButton.center.y-2.5, 5, 5);
    }];
}

@end
