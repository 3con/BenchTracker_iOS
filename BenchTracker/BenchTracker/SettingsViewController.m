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
@property (nonatomic) BTSettings *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.userManager = [BTUserManager sharedInstance];
    self.settings = [BTSettings sharedInstance];
    [self loadForm];
}

- (void)loadForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    form = [XLFormDescriptor formDescriptor];
    
    // Section 1: Edit exercise types
    
    // Section 2: Weight Unit
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"FOOTER";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightInKg" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Weight in kilograms"];
    row.value = [NSNumber numberWithBool:!self.settings.weightInLbs];
    [section addFormRow:row];
    
    // Section 3: Start week on Sunday
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"FOOTER";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startWeekOnSunday" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Start week on Sunday"];
    row.value = [NSNumber numberWithBool:!self.settings.startWeekOnMonday];
    [section addFormRow:row];
    
    // Section 4: Disable screen sleep
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"FOOTER";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disableSleep" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Disable screen sleep"];
    row.value = [NSNumber numberWithBool:self.settings.disableSleep];
    [section addFormRow:row];
    
    // Section 5: Share, Rate
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    //Share
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"share" rowType:XLFormRowDescriptorTypeButton title:@"Share Bench Tracker"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        NSArray* dataToShare = @[@"Go download Bench Tracker on the iOS App Store! https://itunes.apple.com/app/id1097438761"];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                                             applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:^{}];
    };
    [section addFormRow:row];
    //Rate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"rate" rowType:XLFormRowDescriptorTypeButton title:@"Rate Bench Tracker"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    row.action.formBlock = ^(XLFormRowDescriptor * sender){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1097438761&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
    };
    [section addFormRow:row];
    
    // Section 6: Reset data
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"share" rowType:XLFormRowDescriptorTypeButton title:@"Reset Data"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    row.action.formBlock = ^(XLFormRowDescriptor * sender){ [self logOutButtonPressed:nil]; };
    [section addFormRow:row];
    
    self.form = form;
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor *section in self.form.formSections) {
        for (XLFormRowDescriptor * row in section.formRows) {
            if (row.tag && ![row.tag isEqualToString:@""])
                [result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
        }
    }
    self.settings.weightInLbs = ![result[@"weightInKg"] boolValue];
    self.settings.startWeekOnMonday = ![result[@"startWeekOnSunday"] boolValue];
    self.settings.disableSleep = [result[@"disableSleep"] boolValue];
    [self.context save:nil];
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
