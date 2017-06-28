//
//  WorkoutViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutViewController.h"
#import "BTWorkoutManager.h"
#import "ZFModalTransitionAnimator.h"

@interface WorkoutViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property BTWorkoutManager *workoutManager;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameTextField.delegate = self;
    self.workoutManager = [BTWorkoutManager sharedInstance];
    if (!self.workout) self.workout = [self.workoutManager createWorkout];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [self presentAddExerciseViewController];
}

- (IBAction)finishWorkoutButtonPressed:(UIButton *)sender {
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - view handling

- (void)presentAddExerciseViewController {
    AddExerciseViewController *addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ae"];
    addVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:addVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.5;
    self.animator.behindViewScale = 1;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    addVC.transitioningDelegate = self.animator;
    addVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:addVC animated:YES completion:nil];
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameTextField resignFirstResponder];
    return YES;
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
