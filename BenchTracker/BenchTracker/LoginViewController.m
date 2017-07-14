//
//  LoginViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property BOOL isLoginMode;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor BTSecondaryColor];
    self.textField.tintColor = [UIColor BTSecondaryColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loginFieldEnable:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)loginButtonPressed:(UIButton *)sender {
    self.isLoginMode = YES;
    [self loginFieldEnable:YES];
    [self.textField becomeFirstResponder];
}

- (IBAction)createAccountButtonPressed:(UIButton *)sender {
    self.isLoginMode = NO;
    [self loginFieldEnable:YES];
    [self.textField becomeFirstResponder];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self loginFieldEnable:NO];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self.textField resignFirstResponder];
    [self.userManager userExistsWithUsername:self.textField.text continueWithBlock:^(BOOL exists) {
        if (self.isLoginMode && !exists) { //login but no user
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Does Not Exist"
                                                                               message:@"We are sorry, but this username does not exist. Please make sure your username has been entered correctly."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {[self.textField becomeFirstResponder];}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                self.textField.text = @"";
            });
        }
        else if (!self.isLoginMode && exists) { //creating but account already exists
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"User Already Exists"
                                                                               message:@"We are sorry, but this username already exists. Please choose another username."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {[self.textField becomeFirstResponder];}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                self.textField.text = @"";
            });
        }
        else {
            if (self.isLoginMode) { //user logged in
                [self.userManager copyUserFromAWS:self.textField.text completionBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate loginViewController:self willDismissWithUser:[self.userManager user]];
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    });
                }];
            }
            else { //create user with username
                [self.userManager createUserWithUsername:self.textField.text completionBlock:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate loginViewController:self willDismissWithUser:[self.userManager user]];
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    });
                }];
            }
        }
    }];
}

- (void)loginFieldEnable:(BOOL)enable {
    self.textField.alpha = enable;
    self.textField.enabled = enable;
    self.cancelButton.alpha = enable;
    self.cancelButton.enabled = enable;
    self.doneButton.alpha = enable;
    self.doneButton.enabled = enable;
    self.loginButton.alpha = !enable;
    self.loginButton.enabled = !enable;
    self.createAccountButton.alpha = !enable;
    self.createAccountButton.enabled = !enable;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
