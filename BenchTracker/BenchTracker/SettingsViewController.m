//
//  SettingsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SettingsViewController.h"
#import "BTUserManager.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) BTUserManager *userManager;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.userManager = [BTUserManager sharedInstance];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)logOutButtonPressed:(UIButton *)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Log Out?"
                                                                    message:@"Are you sure you want to log out of your account? Your local data stores will have to be re-downloaded if you log in on this device again."
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Log Out" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self.delegate settingsViewControllerDidRequestUserLogout:self];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }];
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
    [alert addAction:cancelButton];
    [alert addAction:deleteButton];
    [self presentViewController:alert animated:YES completion:nil];
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
