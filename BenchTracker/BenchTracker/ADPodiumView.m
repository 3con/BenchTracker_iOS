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
}

- (void)setDates:(NSArray<NSString *> *)dates {
    _dates = dates;
    self.dateLabel3.text = dates[2];
    self.dateLabel2.text = dates[1];
    self.dateLabel1.text = dates[0];
}

- (void)setValues:(NSArray<NSString *> *)values {
    _values = values;
    self.valueLabel3.text = values[2];
    self.valueLabel2.text = values[1];
    self.valueLabel1.text = values[0];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
