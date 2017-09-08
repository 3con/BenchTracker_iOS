//
//  AchievementDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AchievementDetailViewController.h"
#import "BTAchievement+CoreDataClass.h"

@interface AchievementDetailViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containingView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *subnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation AchievementDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.containingView.layer.cornerRadius = 12;
    self.containingView.clipsToBounds = YES;
    if (self.achievement.completed) self.containingView.backgroundColor = [UIColor BTVibrantColors][1];
    else self.containingView.backgroundColor = (self.color) ? self.color : [UIColor BTVibrantColors][0];
    self.badgeView.alpha = self.achievement.completed;
    if (!self.achievement.hidden || self.achievement.completed) {
        self.nameLabel.text = self.achievement.name;
        self.subnameLabel.text = [NSString stringWithFormat:@"%d xp",self.achievement.xp];
        self.detailsLabel.text = self.achievement.details;
    }
    else { //hidden
        self.nameLabel.text = @"???";
        self.subnameLabel.text = @"";
        self.detailsLabel.text = @"";
    }
    self.imageView.image = self.achievement.image;
}

- (void)viewDidLayoutSubviews {
    self.containingView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

- (IBAction)tapGesture2:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

- (IBAction)tapGesture3:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

#pragma mark - scrollView delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    bool neglegable = fabs(velocity.y) < 0.2;
    float offset = fabs(scrollView.contentOffset.y);
    bool offsetPositive = scrollView.contentOffset.y >= 0;
    bool velocityPositive = velocity.y >= 0;
    if (neglegable && offset < 60.0) { } //no dismiss
    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
    else { //dismiss
        [self animateOut];
        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (scrollView.contentOffset.y >= 0)
                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - animation

- (void)animateIn {
    self.containingView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.containingView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    CGPoint endPoint = self.containingView.center;
    self.containingView.center = self.originPoint;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containingView.transform = CGAffineTransformIdentity;
        self.containingView.center = endPoint;
        self.containingView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.containingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
