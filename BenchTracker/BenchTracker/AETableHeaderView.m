//
//  AETableHeaderView.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/30/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AETableHeaderView.h"

@interface AETableHeaderView()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;
@end

@implementation AETableHeaderView

- (void)setDelegate:(id<AETableHeaderViewDelegate>)delegate {
    _delegate = delegate;
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:singleTapRecognizer];
}

- (void)handleTap:(UIGestureRecognizer *)tap {
    self.expanded = !self.expanded;
    [self.delegate headerView:self didChangeExpanded:self.expanded];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.backgroundColor = color;
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    [UIView animateWithDuration:.25 animations:^{
        self.arrowView.transform = CGAffineTransformMakeRotation(M_PI*!expanded);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
