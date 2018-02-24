//
//  ADPodiumView.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADPodiumView.h"

@interface ADPodiumView()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel3;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel2;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel1;

@property (weak, nonatomic) IBOutlet UILabel *subLabel3;
@property (weak, nonatomic) IBOutlet UILabel *subLabel2;
@property (weak, nonatomic) IBOutlet UILabel *subLabel1;

@property (weak, nonatomic) IBOutlet UIView *podiumView3;
@property (weak, nonatomic) IBOutlet UIView *podiumView2;
@property (weak, nonatomic) IBOutlet UIView *podiumView1;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel3;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel1;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint3; //60
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint2; //90
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint1; //120

@end

@implementation ADPodiumView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hasAnimatedIn = NO;
    for (UIView *v in @[self.podiumView1, self.podiumView2, self.podiumView3]) {
        v.layer.cornerRadius = 16;
        v.clipsToBounds = YES;
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.podiumView3.backgroundColor = color;
    self.podiumView2.backgroundColor = color;
    self.podiumView1.backgroundColor = color;
    self.dateLabel3.textColor = color;
    self.dateLabel2.textColor = color;
    self.dateLabel1.textColor = color;
}

- (void)setDates:(NSArray<NSDate *> *)dates {
    _dates = dates;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d ''yy";
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dateLabel3.text = (dates.count > 2) ? [formatter stringFromDate:dates[2]] : @"N/A";
        self.dateLabel2.text = (dates.count > 1) ? [formatter stringFromDate:dates[1]] : @"N/A";
        self.dateLabel1.text = (dates.count > 0) ? [formatter stringFromDate:dates[0]] : @"N/A";
    });
}

- (void)setValues:(NSArray<NSString *> *)values {
    _values = values;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.valueLabel3.text = (values.count > 2) ? values[2] : @"-";
        self.valueLabel2.text = (values.count > 1) ? values[1] : @"-";
        self.valueLabel1.text = (values.count > 0) ? values[0] : @"-";
    });
}

- (void)setSubValues:(NSArray<NSString *> *)subValues {
    _subValues = subValues;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.subLabel3.text = (subValues.count > 2) ? subValues[2] : @"";
        self.subLabel2.text = (subValues.count > 1) ? subValues[1] : @"";
        self.subLabel1.text = (subValues.count > 0) ? subValues[0] : @"";
    });
}

- (void)animateIn {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hasAnimatedIn = YES;
        [self alpa:0 forPodium:3];
        [self alpa:0 forPodium:2];
        [self alpa:0 forPodium:1];
        self.heightConstraint3.constant = 32;
        self.heightConstraint2.constant = 32;
        self.heightConstraint1.constant = 32;
        [self.superview layoutIfNeeded];
        self.heightConstraint3.constant = (self.frame.size.height-50)*.44;
        [UIView animateWithDuration:.5 delay:.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.superview layoutIfNeeded];
            [self alpa:1 forPodium:3];
        } completion:^(BOOL finished) {
            self.heightConstraint2.constant = (self.frame.size.height-50)*.72;
            [UIView animateWithDuration:.5 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.superview layoutIfNeeded];
                [self alpa:1 forPodium:2];
            } completion:^(BOOL finished) {
                self.heightConstraint1.constant = self.frame.size.height-50;
                [UIView animateWithDuration:.5 delay:.25 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    [self.superview layoutIfNeeded];
                    [self alpa:1 forPodium:1];
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    });
}

- (void)alpa:(float)alpha forPodium:(int)podium {
    NSArray *a = (podium == 3)? @[self.dateLabel3, self.valueLabel3, self.subLabel3] : (podium == 2) ?
                                @[self.dateLabel2, self.valueLabel2, self.subLabel2] :
                                @[self.dateLabel1, self.valueLabel1, self.subLabel1];
    for (UIView *v in a) v.alpha = alpha;
}

#pragma mark - helper methods

- (UIColor *)color:(UIColor *)color withMultiplier:(CGFloat)multiplier {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b * multiplier, 1.0) alpha:a];
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
