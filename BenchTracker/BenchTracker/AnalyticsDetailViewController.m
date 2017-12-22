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

- (void)setColor:(UIColor *)color {
    _color = color;
    self.navView.backgroundColor = self.color;
}

- (void)setTitleString:(NSString *)titleString {
    _titleString = titleString;
    self.titleLabel.text = self.titleString;
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
