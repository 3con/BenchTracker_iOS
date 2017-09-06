//
//  UserViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UserViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "UserStatView.h"
#import "BTUser+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray <UIView *> *statContainerViews;

@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTUser *user;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [BTSettings sharedInstance];
    self.user = [BTUser sharedInstance];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    for (int i = 0; i < self.statContainerViews.count; i++) {
        UserStatView *statView = [[NSBundle mainBundle] loadNibNamed:@"UserStatView" owner:self options:nil].firstObject;
        statView.frame = self.statContainerViews[i].bounds;
        statView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        statView.backgroundColor = [UIColor BTVibrantColors][i];
        switch (i) {
            case 0:
                statView.titleLabel.text = @"Member for";
                statView.statLabel.text = [NSString stringWithFormat:@"%.0f days", [[NSDate date] timeIntervalSinceDate:self.user.dateCreated]/86400];
                break;
            case 1:
                statView.titleLabel.text = @"Total Duration";
                statView.statLabel.text = [NSString stringWithFormat:@"%.1f hrs", self.user.totalDuration/3600.0];
                break;
            case 2:
                statView.titleLabel.text = @"# Workouts";
                statView.statLabel.text = [NSString stringWithFormat:@"%lld", self.user.totalWorkouts];
                break;
            case 3:
                statView.titleLabel.text = @"Total Volume";
                statView.statLabel.text = [NSString stringWithFormat:@"%lldk %@",self.user.totalVolume/1000, self.settings.weightSuffix];
                break;
            case 4:
                statView.titleLabel.text = @"Current Streak";
                statView.statLabel.text = [NSString stringWithFormat:@"%lld days", self.user.currentStreak];
                break;
            default:
                statView.titleLabel.text = @"Longest Streak";
                statView.statLabel.text = [NSString stringWithFormat:@"%lld days", self.user.longestStreak];
                break;
        }
        [self.statContainerViews[i] addSubview:statView];
    }
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
}

- (void)presentSettingsViewController {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"s"];
    settingsVC.delegate = self;
    settingsVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:settingsVC];
    self.animator.bounces = NO;
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    settingsVC.transitioningDelegate = self.animator;
    settingsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

#pragma mark - settingsVC delegate

- (void)settingsViewWillDismiss:(SettingsViewController *)settingsVC {
    [self.delegate userViewControllerSettingsDidUpdate:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
