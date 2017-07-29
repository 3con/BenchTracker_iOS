//
//  SettingsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SettingsViewController.h"
#import "BTUserManager.h"
#import "BTButtonFormCell.h"
#import "ZFModalTransitionAnimator.h"
#import "EditExercisesViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) ZFModalTransitionAnimator *animator;

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
    [self.view sendSubviewToBack:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
}

- (void)loadForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    form = [XLFormDescriptor formDescriptor];
    
    // Section 1: Edit exercise types
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Customize the exercises and variations you can choose from when working out.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"editExercises" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Edit exercises"];
    [section addFormRow:row];
    
    // Section 2: Weight Unit
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Show all weights in 🇪🇺 (kg). 🇺🇸 (lbs) is the default.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightInKg" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Weight in kilograms"];
    row.value = [NSNumber numberWithBool:!self.settings.weightInLbs];
    //WARN USER PAST WORKOUTS WILL NOT BE ADJUSTED
    [section addFormRow:row];
    
    // Section 3: Start week on Sunday
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Start your workout week on Sunday. Monday is the default.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startWeekOnSunday" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Start week on Sunday"];
    row.value = [NSNumber numberWithBool:!self.settings.startWeekOnMonday];
    [section addFormRow:row];
    
    // Section 4: Disable screen sleep
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Prevent your device from going to sleep while you are in the process of working out.";
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
    [section addFormRow:row];
    //Rate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"rate" rowType:XLFormRowDescriptorTypeButton title:@"Rate Bench Tracker"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [section addFormRow:row];
    
    // Section 6: Reset data
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reset" rowType:XLFormRowDescriptorTypeBTButton title:@"Reset Data"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [section addFormRow:row];
    
    for (XLFormSectionDescriptor *section in form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            [row.cellConfig setObject:[UIColor BTBlackColor] forKey:@"textLabel.textColor"];
        }
    }
    self.form = form;
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor *section in self.form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            if (row.tag && ![row.tag isEqualToString:@""])
                [result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
        }
    }
    self.settings.weightInLbs = ![result[@"weightInKg"] boolValue];
    self.settings.startWeekOnMonday = ![result[@"startWeekOnSunday"] boolValue];
    self.settings.disableSleep = [result[@"disableSleep"] boolValue];
    [self.context save:nil];
    [self.delegate settingsViewWillDismiss:self];
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

#pragma mark - XLForm delegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    if ([formRow.title containsString:@"eight"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                        message:@"Please be aware that changing your weight units WILL NOT adjust the relative weights of your previous workouts. Instead, they will simply display as the other unit and remain un-converted."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if ([formRow.tag isEqualToString:@"editExercises"]) [self presentEditExercisesViewController];
    else if ([formRow.tag isEqualToString:@"share"]) {
        NSArray* dataToShare = @[@"Go download Bench Tracker on the iOS App Store! https://itunes.apple.com/app/id1097438761"];
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                                             applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else if ([formRow.tag isEqualToString:@"rate"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1097438761&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
    else if ([formRow.tag isEqualToString:@"reset"]) {
        //WARN USER DATA WILL BE DELETED, SUGGEST DOWNLOADING DATA
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Reset Data"
                                                                        message:@"Are you sure you want to reset your accout? You will lose all you hard work! This action cannot be undone."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self logOutButtonPressed:nil]; });
        }];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - view handling

- (void)presentEditExercisesViewController {
    EditExercisesViewController *eeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ee"];
    //eeVC.delegate = self;
    eeVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:eeVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    eeVC.transitioningDelegate = self.animator;
    eeVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:eeVC animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
