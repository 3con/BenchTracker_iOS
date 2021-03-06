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
#import "LeaderboardViewButton.h"
#import "AchievementsViewController.h"
#import "LeaderboardViewController.h"
#import "BTAchievement+CoreDataClass.h"
#import "WZLBadgeImport.h"
#import "UserView.h"
#import "UserStats.h"

@interface UserViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (nonatomic) UserView *userView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) AchievementViewButton *achievementButton;
@property (weak, nonatomic) LeaderboardViewButton *leaderboardButton;
@property (nonatomic) NSMutableArray <UserStatView *> *statViews;
@property (nonatomic) CGFloat numRows;
@property (nonatomic) CGFloat buttonHeight;
@property (nonatomic) CGFloat interLineSpacing;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlView;

@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTUser *user;
@property (nonatomic) UserStats *userStats;

@property (nonatomic) int statsOffset;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorSchemeChange:)
                                                 name:@"colorSchemeChange" object:nil];
    [self updateInterface];
    self.settings = [BTSettings sharedInstance];
    self.user = [BTUser sharedInstance];
    self.userStats = [UserStats statsWithUser:self.user settings:self.settings];
    [BTUser updateStreaks];
    self.statsOffset = 0;
    [Log event:@"UserVC: Presentation" properties:nil];
}

- (void)updateInterface {
    [self.userView updateInterface];
    self.pageControlView.pageIndicatorTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.6];
    self.pageControlView.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    self.view.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    [self.backButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    [self.settingsButton setImage:[[UIImage imageNamed:@"Settings"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                         forState:UIControlStateNormal];
    self.settingsButton.tintColor = [UIColor BTTextPrimaryColor];
}

- (void)colorSchemeChange:(NSNotification *)notification  {
    [self updateInterface];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.containerView.subviews.count == 1) { //first load
        self.numRows = 5;
        self.interLineSpacing = 10;
        self.buttonHeight = (self.containerView.frame.size.height-self.interLineSpacing*self.numRows)/self.numRows;
        [self loadAchievementButton];
        [self loadLeaderboardButton];
        self.statViews = @[].mutableCopy;
        [self refreshStats];
        [self loadSwitchStatsButton];
        [self loadUserView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [(UserView *)self.userContainerView.subviews.firstObject animateIn];
    [self updateAchievementButton];
    if (self.forwardToAcheivements) {
        [self presentAchievementsViewController];
        self.forwardToAcheivements = NO;
    }
}

- (void)refreshStats {
    for (int i = 0; i < (self.numRows-2)*2; i++) {
        UserStatView *statView = (self.statViews.count <= i) ? nil : self.statViews[i];
        if (!statView) {
            statView = [[NSBundle mainBundle] loadNibNamed:@"UserStatView" owner:self options:nil].firstObject;
            CGFloat w = self.containerView.frame.size.width;
            statView.frame = CGRectMake((i%2)*(w/2.0+self.interLineSpacing/2.0), (self.buttonHeight+self.interLineSpacing)*(2+i/2),
                                        w/2-self.interLineSpacing/2.0, self.buttonHeight);
            statView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            statView.backgroundColor = (i >= 5) ? [UIColor BTButtonPrimaryColor] : [UIColor BTVibrantColors][i+2];
            [self.containerView addSubview:statView];
            [self.statViews addObject:statView];
        }
        statView.titleLabel.text = [self.userStats statForIndex:i+self.statsOffset*(self.numRows-2)*2][0];
        statView.statLabel.text = [self.userStats statForIndex:i+self.statsOffset*(self.numRows-2)*2][1];
    }
}

- (void)loadAchievementButton {
    self.achievementButton = [[NSBundle mainBundle] loadNibNamed:@"AchievementViewButton" owner:self options:nil].firstObject;
    self.achievementButton.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.buttonHeight);
    self.achievementButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.achievementButton addTarget:self action:@selector(achievementViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.achievementButton];
}

- (void)loadLeaderboardButton {
    self.leaderboardButton = [[NSBundle mainBundle] loadNibNamed:@"LeaderboardViewButton" owner:self options:nil].firstObject;
    self.leaderboardButton.frame = CGRectMake(0, self.buttonHeight+self.interLineSpacing, self.containerView.frame.size.width, self.buttonHeight);
    self.leaderboardButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.leaderboardButton addTarget:self action:@selector(leaderboardViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.leaderboardButton];
}

- (void)loadSwitchStatsButton {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, (self.buttonHeight+self.interLineSpacing)*2,
        self.containerView.frame.size.width, (self.buttonHeight+self.interLineSpacing)*(self.numRows-2))];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(switchStatsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:button];
}

- (void)updateAchievementButton {
    NSInteger num = [BTAchievement numberOfUnreadAchievements];
    if (num) {
        [self.achievementButton showBadgeWithStyle:WBadgeStyleNumber value:num animationType:WBadgeAnimTypeNone];
        self.achievementButton.badgeFrame = CGRectMake(0, 0, 32, 32);
        self.achievementButton.badge.layer.cornerRadius = 16;
        self.achievementButton.badgeCenterOffset = CGPointMake(-12, 10);
        self.achievementButton.badgeFont = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    }
    else [self.achievementButton clearBadge];
}

- (void)loadUserView {
    self.userView = [[NSBundle mainBundle] loadNibNamed:@"UserView" owner:self options:nil].firstObject;
    self.userView.frame = self.userContainerView.bounds;
    self.userView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.userView loadUser:self.user];
    [self.userContainerView addSubview:self.userView];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
}

- (void)achievementViewButtonPressed:(id)sender {
    [self presentAchievementsViewController];
}

- (void)leaderboardViewButtonPressed:(id)sender {
    [self presentLeaderboardViewController];
}

- (IBAction)switchStatsButtonPressed:(UIButton *)sender {
    [self animateCells];
    self.statsOffset = (self.statsOffset+1)%(self.userStats.numStats/(int)((self.numRows-2)*2));
    [Log event:@"UserVC: Switch stats" properties:@{@"Offset": @(self.statsOffset)}];
    self.pageControlView.currentPage = self.statsOffset;
    [self refreshStats];
}

-(void)animateCells {
    for (int i = 0; i < self.statViews.count; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.statViews[i] cache:YES];
        [UIView setAnimationDelay:i*.1];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView commitAnimations];
    }
}

- (void)presentAchievementsViewController {
    AchievementsViewController *aVC = [self.storyboard instantiateViewControllerWithIdentifier:@"av"];
    aVC.settings = self.settings;
    aVC.context = self.context;
    [self presentViewController:aVC withStyle:BTPresentationStyleFromRight];
}

- (void)presentLeaderboardViewController {
    LeaderboardViewController *lVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ld"];
    lVC.context = self.context;
    [self presentViewController:lVC withStyle:BTPresentationStyleFromRight];
}

- (void)presentSettingsViewController {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"s"];
    settingsVC.delegate = self;
    settingsVC.context = self.context;
    [self presentViewController:settingsVC withStyle:BTPresentationStyleFromRight];
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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
