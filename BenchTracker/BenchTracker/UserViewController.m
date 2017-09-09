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
#import "BTWorkout+CoreDataClass.h"
#import "AchievementViewButton.h"
#import "AchievementsViewController.h"
#import "BTAchievement+CoreDataClass.h"
#import "WZLBadgeImport.h"

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIView *achievementButtonContainerView;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray <UIView *> *statContainerViews;

@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTUser *user;

@property (nonatomic) BOOL isShowingFirstStats;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [BTSettings sharedInstance];
    self.user = [BTUser sharedInstance];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.isShowingFirstStats = YES;
    [self refreshStats];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadAchievementButton];
}

- (void)refreshStats {
    for (int i = 0; i < self.statContainerViews.count; i++) {
        UserStatView *statView;
        if (self.statContainerViews[i].subviews.count == 0) {
            statView = [[NSBundle mainBundle] loadNibNamed:@"UserStatView" owner:self options:nil].firstObject;
            statView.frame = self.statContainerViews[i].bounds;
            statView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            statView.backgroundColor = [UIColor BTVibrantColors][i+1];
        }
        else statView = self.statContainerViews[i].subviews.firstObject;
        switch (i) {
            case 0:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"Tracking for" : @"Workout %";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%.0f days", [[NSDate date] timeIntervalSinceDate:self.user.dateCreated]/86400+1] :
                    [NSString stringWithFormat:@"%.0f%%", ((float)self.user.totalWorkouts)/
                                                          ([[NSDate date] timeIntervalSinceDate:self.user.dateCreated]/86400+1)*100];
                break;
            case 1:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"Total Duration" : @"Volume / Hour";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%.1f hrs", self.user.totalDuration/3600.0] :
                    [NSString stringWithFormat:@"%.1fk %@", self.user.totalVolume/1000.0/self.user.totalDuration*3600, self.settings.weightSuffix];
                break;
            case 2:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"# of Workouts" : @"Average Duration";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%lld", self.user.totalWorkouts] :
                    [NSString stringWithFormat:@"%.1f min", self.user.totalDuration/60.0/self.user.totalWorkouts];
                break;
            case 3:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"Total Volume" : @"Average Volume";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%lldk %@", self.user.totalVolume/1000, self.settings.weightSuffix] :
                    [NSString stringWithFormat:@"%.1fk %@", self.user.totalVolume/1000.0/self.user.totalWorkouts, self.settings.weightSuffix];
                break;
            case 4:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"Current Streak" : @"Longest Duration";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%lld days", self.user.currentStreak] :
                    [NSString stringWithFormat:@"%ld min", [self maxWorkoutDuration]/60];
                break;
            default:
                statView.titleLabel.text = (self.isShowingFirstStats) ? @"Longest Streak" : @"Highest Volume";
                statView.statLabel.text = (self.isShowingFirstStats) ?
                    [NSString stringWithFormat:@"%lld days", self.user.longestStreak] :
                    [NSString stringWithFormat:@"%ldk %@",[self maxWorkoutVolume]/1000, self.settings.weightSuffix];
                break;
        }
        [self.statContainerViews[i] addSubview:statView];
    }
}

- (void)loadAchievementButton {
    AchievementViewButton *button = [[NSBundle mainBundle] loadNibNamed:@"AchievementViewButton" owner:self options:nil].firstObject;
    button.frame = self.achievementButtonContainerView.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [button addTarget:self action:@selector(achievementViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.achievementButtonContainerView addSubview:button];
    NSInteger num = [BTAchievement numberOfUnreadAchievements];
    if (num) {
        [self.achievementButtonContainerView showBadgeWithStyle:WBadgeStyleNumber value:num animationType:WBadgeAnimTypeNone];
        self.achievementButtonContainerView.badgeFrame = CGRectMake(0, 0, 32, 32);
        self.achievementButtonContainerView.badge.layer.cornerRadius = 16;
        self.achievementButtonContainerView.badgeCenterOffset = CGPointMake(-6, 6);
        self.achievementButtonContainerView.badgeFont = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    }
    else [self.achievementButtonContainerView clearBadge];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
}

- (void)achievementViewButtonPressed:(id)sender {
    [self presentAchievementsViewController];
    [BTAchievement resetUnreadAcheivements];
}

- (IBAction)switchStatsButtonPressed:(UIButton *)sender {
    self.isShowingFirstStats = !self.isShowingFirstStats;
    [self refreshStats];
}

- (void)presentAchievementsViewController {
    AchievementsViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"av"];
    aVC.settings = self.settings;
    aVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:aVC];
    self.animator.bounces = NO;
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    aVC.transitioningDelegate = self.animator;
    aVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:aVC animated:YES completion:nil];
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

#pragma mark - helper methods

- (NSInteger)maxWorkoutDuration {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO]];
    NSArray <BTWorkout *> *arr = [self.context executeFetchRequest:fetchRequest error:nil];
    return (arr && arr.count > 0) ? arr.firstObject.duration : 0;
}

- (NSInteger)maxWorkoutVolume {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:NO]];
    NSArray <BTWorkout *> *arr = [self.context executeFetchRequest:fetchRequest error:nil];
    return (arr && arr.count > 0) ? arr.firstObject.volume : 0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
