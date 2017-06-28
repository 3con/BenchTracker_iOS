//
//  MainViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "MainViewController.h"
#import "BTUserManager.h"
#import "ZFModalTransitionAnimator.h"

@interface MainViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTUserManager *userManager;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userManager = [BTUserManager sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.userManager user]) { //No user in CoreData
        [self presentLoginViewController];
    }
}

- (void)presentLoginViewController {
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"l"];
    loginVC.userManager = self.userManager;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:loginVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    loginVC.transitioningDelegate = self.animator;
    loginVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:loginVC animated:YES completion:nil];
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
