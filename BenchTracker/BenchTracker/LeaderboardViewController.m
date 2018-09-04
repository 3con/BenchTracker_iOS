//
//  LeaderboardViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "LeaderboardTableViewCell.h"
#import "BTUser+CoreDataClass.h"
#import "AWSLeaderboard.h"

@interface LeaderboardViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonnull) NSArray<AWSLeaderboard *> *leaderboard;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;
@property (weak, nonatomic) IBOutlet UILabel *localRankView;
@property (nonatomic) NSNumber *localRank;
@property (weak, nonatomic) IBOutlet UILabel *localUsernameView;
@property (weak, nonatomic) IBOutlet UILabel *localScoreView;

@property (nonatomic) BTUser *user;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTVibrantColors][1];
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.user = [BTUser sharedInstance];
    [self refreshLeaderboard];
    [Log event:@"LeaderboardVC: Presentation" properties:nil];
}

- (void)refreshLeaderboard {
    [self.user topLevelsWithCompletionBlock:^(NSArray<AWSLeaderboard *> *topLevels) {
        for (NSInteger i = 0; i < topLevels.count; i++) {
            if ([topLevels[i].username isEqualToString:self.user.name]) {
                self.localRank = [NSNumber numberWithInteger:i];
                break;
            }
        }
        self.leaderboard = topLevels;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.localRankView.text = (self.localRank) ? [NSString stringWithFormat:@"%ld.",self.localRank.integerValue+1] : @"100+";
            [self.activityIndicator stopAnimating];
            [self.tableView reloadData];
        });
    }];
    self.localRankView.text = @"-";
    self.localUsernameView.text = self.user.name;
    self.localScoreView.text = [NSString stringWithFormat:@"%d xp", self.user.xp];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editUsernameButtonPressed:(UIButton *)sender {
    [self presentEditUsernameViewControllerWithPoint: [self.bottomContainerView convertPoint:sender.center toView:self.view]];
}

#pragma mark - tableView delegate / dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.leaderboard.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LeaderboardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) cell = [[NSBundle mainBundle] loadNibNamed:@"LeaderboardTableViewCell" owner:self options:nil].firstObject;
    cell.rank = indexPath.row+1;
    AWSLeaderboard *leader = self.leaderboard[indexPath.row];
    cell.titleLabel.text = leader.username;
    cell.statLabel.text = [NSString stringWithFormat:@"%@ xp", leader.experience];
    cell.isSelf = (self.localRank && indexPath.row == self.localRank.integerValue);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.localRank.integerValue)
        [self presentEditUsernameViewControllerWithPoint:
            [self.tableView convertPoint:[tableView cellForRowAtIndexPath:indexPath].center toView:self.view]];
}

#pragma mark - editUsernameVC delegate

- (void)editUsernameViewControllerWillDismissWithUpdatedUsername:(EditUsernameViewController *)euVC {
    [self refreshLeaderboard];
}

#pragma mark - view handling

- (void)presentEditUsernameViewControllerWithPoint:(CGPoint)point {
    EditUsernameViewController *euVC = [self.storyboard instantiateViewControllerWithIdentifier:@"eu"];
    euVC.delegate = self;
    euVC.user = self.user;
    euVC.originPoint = point;
    [self presentViewController:euVC withStyle:BTPresentationStyleNone];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
