//
//  AnalyticsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "BTWorkoutManager.h"
#import "BTSettings+CoreDataClass.h"

@interface AnalyticsViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
