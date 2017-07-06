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
- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - view handling

- (void)presentSettingsViewController {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"s"];
    settingsVC.delegate = self;
    settingsVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:settingsVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    settingsVC.transitioningDelegate = self.animator;
    settingsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

#pragma mark - settingsVC delegate

- (void)settingsViewControllerDidRequestUserLogout:(SettingsViewController *)settingsVC {
    
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
