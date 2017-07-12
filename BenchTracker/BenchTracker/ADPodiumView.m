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

@property (weak, nonatomic) IBOutlet UIView *podiumView3;
@property (weak, nonatomic) IBOutlet UIView *podiumView2;
@property (weak, nonatomic) IBOutlet UIView *podiumView1;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel3;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel2;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel1;

@end

@implementation ADPodiumView

- (void)awakeFromNib {
    [super awakeFromNib];
    for (UIView *v in @[self.podiumView1, self.podiumView2, self.podiumView3]) {
        v.layer.cornerRadius = 8;
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
    self.dateLabel3.text = (dates.count > 2) ? [formatter stringFromDate:dates[2]] : @"";
    self.dateLabel2.text = (dates.count > 1) ? [formatter stringFromDate:dates[1]] : @"";
    self.dateLabel1.text = (dates.count > 0) ? [formatter stringFromDate:dates[0]] : @"";
}

- (void)setValues:(NSArray<NSString *> *)values {
    _values = values;
    self.valueLabel3.text = (values.count > 2) ? values[2] : @"";
    self.valueLabel2.text = (values.count > 1) ? values[1] : @"";
    self.valueLabel1.text = (values.count > 0) ? values[0] : @"";
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
