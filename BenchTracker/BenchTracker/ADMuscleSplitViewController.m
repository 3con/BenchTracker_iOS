//
//  ADMuscleSplitViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADMuscleSplitViewController.h"
#import "ADMuscleSplitTableViewCell.h"
#import "BTUserManager.h"
#import "BTWorkoutManager.h"

@interface ADMuscleSplitViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTUser *user;

@end

@implementation ADMuscleSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [(BTUserManager *)[BTUserManager sharedInstance] user];
    self.workoutManager = [BTWorkoutManager sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleString = @"Muscle Split";
}

#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 190;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMuscleSplitTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ADMuscleSplitTableViewCell" owner:self options:nil].firstObject;
        cell.color = self.color;
    }
    [cell loadWithDate:nil workouts:nil];
    return cell;
}

#pragma mark - tableView delegate

@end
