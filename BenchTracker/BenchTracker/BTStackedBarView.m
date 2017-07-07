//
//  BTStackedBarView.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTStackedBarView.h"

@interface BTStackedBarView ()

@property (nonatomic) NSMutableArray <NSNumber *> *barValues;
@property (nonatomic) NSMutableArray <NSNumber *> *subSums;
@property (nonatomic) NSMutableArray <UIView *> *barViews;
@property (nonatomic) NSMutableArray <UILabel *> *labelViews;

@end

@implementation BTStackedBarView

- (void)reloadData {
    if (self.dataSource) {
        [self setNeedsLayout];
        [self layoutIfNeeded];
        [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        self.barValues = [NSMutableArray array];
        self.subSums = [NSMutableArray array];
        self.barViews = [NSMutableArray array];
        self.labelViews = [NSMutableArray array];
        NSInteger numBars = [self.dataSource numberOfBarsForStackedBarView:self];
        NSInteger sum = 0;
        for (NSInteger i = 0; i < numBars; i++) {
            NSInteger val = [self.dataSource stackedBarView:self valueForBarAtIndex:i];
            [self.barValues addObject:[NSNumber numberWithInteger:val]];
            [self.subSums addObject:[NSNumber numberWithInteger:sum]];
            sum += val;
        }
        for (int i = 0; i < self.barValues.count; i++) {
            float barWidth = self.barValues[i].floatValue / sum * self.bounds.size.width;
            float barXPos = self.subSums[i].floatValue / sum * self.bounds.size.width;
            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(barXPos, 0, barWidth, self.bounds.size.height)];
            id color;
            if ([self.dataSource respondsToSelector:@selector(stackedBarView:colorForBarAtIndex:)])
                color = [self.dataSource stackedBarView:self colorForBarAtIndex:i];
            if ([color isKindOfClass:[UIColor class]]) bar.backgroundColor = color;
            else bar.backgroundColor = [UIColor colorWithWhite:(arc4random()%180/256.0) alpha:1.0];
            [self addSubview:bar];
            if ([self.dataSource respondsToSelector:@selector(stackedBarView:nameForBarAtIndex:)]) {
                UILabel *barLabel = [[UILabel alloc] init];
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationDuration:0];
                [barLabel setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
                barLabel.frame = CGRectMake(barXPos, 2, 10, self.bounds.size.height-4);
                [UIView commitAnimations];
                barLabel.text = [[self.dataSource stackedBarView:self nameForBarAtIndex:i] componentsSeparatedByString:@" "].firstObject;
                barLabel.font = [UIFont systemFontOfSize:8 weight:UIFontWeightBold];
                barLabel.adjustsFontSizeToFitWidth = YES;
                barLabel.minimumScaleFactor = .7;
                barLabel.allowsDefaultTighteningForTruncation = YES;
                barLabel.textAlignment = NSTextAlignmentCenter;
                const CGFloat *components = CGColorGetComponents(((UIColor *)color).CGColor);
                CGFloat colorBrightness = 0;
                if (components) colorBrightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000;
                barLabel.textColor = (colorBrightness > .75) ? [UIColor blackColor] : [UIColor whiteColor];
                [self addSubview:barLabel];
            }
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
