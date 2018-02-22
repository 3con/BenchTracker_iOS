//
//  SettingsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SettingsViewController.h"
#import "BTButtonFormCell.h"
#import "ZFModalTransitionAnimator.h"
#import "EditExercisesViewController.h"
#import "EditSmartNamesViewController.h"
#import "BTSettings+CoreDataClass.h"
#import "BTDataTransferManager.h"
#import "BTAchievement+CoreDataClass.h"
#import "AppDelegate.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BTSettings *settings;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateInterface];
    self.settings = [BTSettings sharedInstance];
    self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0);
    [self loadForm];
    [self.view sendSubviewToBack:self.tableView];
}

- (void)updateInterface {
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.backButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    self.tableView.backgroundColor = [UIColor BTGroupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self saveSettings];
    [self.delegate settingsViewWillDismiss:self];
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
    
    // Section 2: Dark Mode
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Enable an app-wide dark mode.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"darkMode" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Dark mode"];
    row.value = [NSNumber numberWithBool:[UIColor colorScheme] == 1];
    [section addFormRow:row];
    
    // Section 3: Weight Unit
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Show all weights in 🇪🇺 (kg). 🇺🇸 (lbs) is the default.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"weightInKg" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Weight in kilograms"];
    row.value = [NSNumber numberWithBool:!self.settings.weightInLbs];
    //WARN USER PAST WORKOUTS WILL NOT BE ADJUSTED
    [section addFormRow:row];
    
    if (@available(iOS 11, *)) {
        // Section 4: Workout smart names
        section = [XLFormSectionDescriptor formSection];
        section.footerTitle = @"Weightlifting App will use machine learning to automatically determine a smart name for your workout based on the exercises you perform.";
        [form addFormSection:section];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"showSmartNames" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Workout smart names"];
        row.value = [NSNumber numberWithBool:self.settings.showSmartNames];
        [section addFormRow:row];
        row = [XLFormRowDescriptor formRowDescriptorWithTag:@"editSmartNames" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Edit smart names"];
        [section addFormRow:row];
    }
    
    // Section 5: Start week on Sunday
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Start your workout week on Sunday. Monday is the default.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startWeekOnSunday" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Start week on Sunday"];
    row.value = [NSNumber numberWithBool:!self.settings.startWeekOnMonday];
    [section addFormRow:row];
    
    // Section 6: Disable screen sleep
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Prevent your device from going to sleep while you are in the process of working out.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"disableSleep" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Disable screen sleep"];
    row.value = [NSNumber numberWithBool:self.settings.disableSleep];
    [section addFormRow:row];
    
    // Section 7: Workout details
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Displays statistics below each workout in your home screen.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"workoutDetails" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Show workout details"];
    row.value = [NSNumber numberWithBool:self.settings.showWorkoutDetails];
    [section addFormRow:row];
    
    // Section 8: Show in exercise view
    section = [XLFormSectionDescriptor formSection];
    section.title = @"SHOW IN EXERCISE VIEW";
    section.footerTitle = @"Exercise analytics: displays analytics relating to the exercise you are performing.\nEquivalency chart: displays a chart with equivalent one-rep-maxes for appropriate exercises.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"showLastWorkout" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Exercise analytics"];
    row.value = [NSNumber numberWithBool:self.settings.showLastWorkout];
    [section addFormRow:row];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"showEquivChart" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Equivalency chart"];
    row.value = [NSNumber numberWithBool:self.settings.showEquivalencyChart];
    [section addFormRow:row];
    
    // Section 9: Import, Export data
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"Import or export all of your Weightlifting App data using email attachments. This includes all of your workouts and custom exercises. Open your data on another phone to transfer your gains.";
    [form addFormSection:section];
    //Import
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"import" rowType:XLFormRowDescriptorTypeButton title:@"Import data"];
    [section addFormRow:row];
    //Export
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"export" rowType:XLFormRowDescriptorTypeButton title:@"Export all data"];
    [section addFormRow:row];
    
    // Section 10: Share, Rate
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    //Share
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"share" rowType:XLFormRowDescriptorTypeButton title:@"Share Weightlifting App"];
    [section addFormRow:row];
    //Rate
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"rate" rowType:XLFormRowDescriptorTypeButton title:@"Rate Weightlifting App"];
    [section addFormRow:row];
    
    // Section 11: Reset data
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reset" rowType:XLFormRowDescriptorTypeBTButton title:@"Reset Data"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    [section addFormRow:row];
    
    for (XLFormSectionDescriptor *section in form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            row.cellConfig[@"backgroundColor"] = [UIColor colorWithWhite:.64 alpha:.1];
            row.cellConfig[@"textLabel.textColor"] = [UIColor BTBlackColor];
            row.cellConfig[@"textLabel.textAlignment"] = @(NSTextAlignmentNatural);
        }
    }
    self.form = form;
}

- (void)saveSettings {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor *section in self.form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            if (row.tag && ![row.tag isEqualToString:@""])
                [result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
        }
    }
    [UIColor changeColorSchemeTo:([result[@"darkMode"] boolValue])];
    self.settings.weightInLbs = ![result[@"weightInKg"] boolValue];
    self.settings.startWeekOnMonday = ![result[@"startWeekOnSunday"] boolValue];
    self.settings.disableSleep = [result[@"disableSleep"] boolValue];
    self.settings.showSmartNames = [result[@"showSmartNames"] boolValue];
    self.settings.showWorkoutDetails = [result[@"workoutDetails"] boolValue];
    self.settings.showLastWorkout = [result[@"showLastWorkout"] boolValue];
    self.settings.showEquivalencyChart = [result[@"showEquivChart"] boolValue];
    [self.context save:nil];
}

- (IBAction)resetDataButtonPressed:(UIButton *)sender {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] resetCoreData];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Complete"
                                                                   message:@"Weightlifting App has reset your data. The app will now close to complete the process."
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        assert(! "BT: User reset data. Intentional crash.");
    }];
    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - XLForm delegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    if ([formRow.tag isEqualToString:@"darkMode"]) {
        [UIColor changeColorSchemeTo:[formRow.value intValue]];
        [self updateInterface];
        [self saveSettings];
        [self loadForm];
    }
    else if ([formRow.tag isEqualToString:@"weightInKg"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                        message:@"Please be aware that changing your weight units WILL NOT adjust the relative weights of your previous workouts. Instead, they will simply display as the other unit and remain un-converted."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if ([formRow.tag isEqualToString:@"editExercises"]) [self presentEditExercisesViewController];
    else if ([formRow.tag isEqualToString:@"editSmartNames"]) [self presentEditSmartNamesViewController];
    else if ([formRow.tag isEqualToString:@"import"]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import Data"
                                                                       message:@"To import your Weightlifting App data, please open an email with the compatible '.wld' file. Then, tap on the file to open it in the Weightlifting App."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if ([formRow.tag isEqualToString:@"export"]) {
        [self saveSettings];
        NSString *dataPath = [BTDataTransferManager pathForJSONDataExport];
        NSData *BTData = [[NSFileManager defaultManager] contentsAtPath:dataPath];
        if (BTData != nil) {
            MFMailComposeViewController *email = [[MFMailComposeViewController alloc] init];
            if (!email) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Export Data"
                                                                               message:@"Unfortunatly, we can not export your data at this time. This may be becuase you have not set up system email or iMessage. We are sorry for the inconvenience."
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            }
            else {
                [email setSubject:@"Weightlifting App Data"];
                [email addAttachmentData:BTData mimeType:@"application/benchtracker" fileName:@"Weightlifting App Data"];
                [email setToRecipients:[NSArray array]];
                [email setMessageBody:@"Here's my Weightlifting App data. Once you have the Weightlifting App, tap on the file to open it." isHTML:NO];
                [email setMailComposeDelegate:self];
                [self presentViewController:email animated:YES completion:nil];
            }
        }
    }
    else if ([formRow.tag isEqualToString:@"share"]) {
        NSArray *dataToShare = @[@"Go download Weightlifting App on the iOS App Store! https://itunes.apple.com/app/id1266077653"];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                                                                             applicationActivities:nil];
        [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if (completed) [BTAchievement markAchievementComplete:ACHIEVEMENT_SHARE animated:YES];
        }];
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else if ([formRow.tag isEqualToString:@"rate"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1266077653&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"]];
    else if ([formRow.tag isEqualToString:@"reset"]) {
        //WARN USER DATA WILL BE DELETED, SUGGEST DOWNLOADING DATA
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Reset Data"
                                                                        message:@"Are you sure you want to reset your accout? You will lose all your hard work! We suggest saving your data beforehand by exporting your data or printing out your workouts. This action cannot be undone."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{ [self resetDataButtonPressed:nil]; });
        }];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - mailVC delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - view handling

- (void)presentEditExercisesViewController {
    EditExercisesViewController *eeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ee"];
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

- (void)presentEditSmartNamesViewController {
    EditSmartNamesViewController *esnVC = [[EditSmartNamesViewController alloc] initWithNibName:@"EditSmartNamesViewController"
                                                                                         bundle:[NSBundle mainBundle]];
    esnVC.context = self.context;
    esnVC.settings = self.settings;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:esnVC];
    self.animator.bounces = NO;
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    esnVC.transitioningDelegate = self.animator;
    esnVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:esnVC animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
