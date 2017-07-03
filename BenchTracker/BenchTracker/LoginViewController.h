//
//  LoginViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTUserManager.h"

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>
- (void)loginViewController:(LoginViewController *)loginVC willDismissWithUser:(BTUser *)user;
@end

@interface LoginViewController : UIViewController

@property (nonatomic) id<LoginViewControllerDelegate> delegate;

@property (nonatomic) BTUserManager *userManager;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end
