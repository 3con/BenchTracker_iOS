//
//  QRDisplayViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "QRDisplayViewController.h"

@interface QRDisplayViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@end

@implementation QRDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.backgroundView.backgroundColor = [UIColor BTModalViewBackgroundColor];
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    self.doneButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.doneButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.doneButton.alpha = 0.0;
    self.doneButton.layer.cornerRadius = 12;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.imageView1.image = self.image1;
    self.imageView2.image = self.image2;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate QRDisplayViewControllerWillDismiss:self];
    [self animateOut];
}

#pragma mark - scrollView delegate

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
//              targetContentOffset:(inout CGPoint *)targetContentOffset {
//    bool neglegable = fabs(velocity.y) < 0.2;
//    float offset = fabs(scrollView.contentOffset.y);
//    bool offsetPositive = scrollView.contentOffset.y >= 0;
//    bool velocityPositive = velocity.y >= 0;
//    if (neglegable && offset < 60.0) { } //no dismiss
//    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
//    else { //dismiss
//        [self animateOut];
//        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            if (scrollView.contentOffset.y >= 0)
//                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
//            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
//        } completion:^(BOOL finished) {}];
//    }
//}

#pragma mark - animation

- (void)animateIn {
    self.backgroundView.alpha = 0.0;
    self.contentView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.contentView.alpha = 0.5;
    self.contentView.center = self.point;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.center = CGPointMake(self.view.center.x, self.view.center.y-35);
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
        self.doneButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        self.doneButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.delegate QRDisplayViewControllerWillDismiss:self];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
