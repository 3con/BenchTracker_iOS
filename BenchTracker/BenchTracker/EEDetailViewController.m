//
//  EEDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EEDetailViewController.h"

@interface EEDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@end

@implementation EEDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.delegate editExerciseDetailViewController:self willDismissWithResultExerciseType:self.type];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
