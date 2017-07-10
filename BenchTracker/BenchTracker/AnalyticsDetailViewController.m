//
//  AnalyticsDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsDetailViewController.h"

@interface AnalyticsDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation AnalyticsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navView.backgroundColor = self.color;
    self.titleLabel.text = self.titleString;
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
