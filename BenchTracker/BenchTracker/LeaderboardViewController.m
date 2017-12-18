//
//  LeaderboardViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "LeaderboardViewController.h"
#import "LeaderboardTableViewCell.h"
#import "BTUser+CoreDataClass.h"
#import "AWSLeaderboard.h"

@interface LeaderboardViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonnull) NSArray<AWSLeaderboard *> *leaderboard;

@property (weak, nonatomic) IBOutlet UILabel *localRankView;
@property (weak, nonatomic) IBOutlet UILabel *localUsernameView;
@property (weak, nonatomic) IBOutlet UILabel *localScoreView;

@property (nonatomic) BTUser *user;

@end

@implementation LeaderboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTVibrantColors][1];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.allowsSelection = NO;
    self.user = [BTUser sharedInstance];
    [self.user topLevelsWithCompletionBlock:^(NSArray<AWSLeaderboard *> *topLevels) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.leaderboard = topLevels;
            [self.tableView reloadData];
        });
    }];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    cell.isSelf = leader.experience.longValue == self.user.xp && [leader.username isEqualToString:self.user.name];
    if (cell.isSelf) {
        self.localRankView.text = [NSString stringWithFormat:@"%ld.",cell.rank];
        self.localUsernameView.text = cell.titleLabel.text;
        self.localScoreView.text = cell.statLabel.text;
    }
    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
