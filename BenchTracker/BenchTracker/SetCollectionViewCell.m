//
//  SetCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SetCollectionViewCell.h"

@interface SetCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@property (weak, nonatomic) IBOutlet UILabel *cornerLabel;

@end

@implementation SetCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    self.cornerLabel.layer.cornerRadius = 7.5;
    self.cornerLabel.clipsToBounds = YES;
}

- (void)loadSetWithString: (NSString *)set {
    self.containerView.frame = CGRectMake(0, 0, 70, 45);
    NSArray *strings = [set componentsSeparatedByString:@" "];
    if ([strings[0] isEqualToString:@"~"]) { //custom
        self.topLabel.text = @"Custom";
        self.bottomLabel.text = [set substringFromIndex:2];
    }
    else if ([strings[0] containsString:@"s"]) {
        if(strings.count == 3) { //timeWeight
            self.topLabel.text = [NSString stringWithFormat:@"%@ lbs",strings[2]];
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ secs",strings[1]];
        }
        else { //time
            self.topLabel.text = @"";
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ secs",strings[1]];
        }
    }
    else {
        if(strings.count == 2) { //repsWeight
            self.topLabel.text = [NSString stringWithFormat:@"%@ reps",strings[0]];
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ lbs",strings[1]];
        }
        else { //reps
            self.topLabel.text = @"";
            self.bottomLabel.text = [NSString stringWithFormat:@"%@ reps",set];
        }
    }
}

- (void)performDeleteAnimationWithDuration: (float)duration {
    [UIView animateWithDuration:duration animations:^{
        self.containerView.frame = CGRectMake(self.cornerLabel.center.x-2.5, self.cornerLabel.center.y-2.5, 5, 5);
    }];
}

@end
