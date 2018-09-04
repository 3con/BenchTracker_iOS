//
//  EditSmartNamesViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 1/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "EditSmartNamesViewController.h"
#import "SmartNameQuestionMarkViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "BTSettings+CoreDataClass.h"
#import "BTButtonFormCell.h"

@interface EditSmartNamesViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic) NSArray *sortedKeys;
@property (nonatomic) NSDictionary *altKeys;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@end

@implementation EditSmartNamesViewController

@dynamic tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sortedKeys = [self.settings.smartNicknameDict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.altKeys = @{@"abs": @"Abs",
                     @"arms": @"Arms",
                     @"back": @"Back",
                     @"cardio": @"Cardio",
                     @"chest": @"Chest",
                     @"legs": @"Legs",
                     @"shoulders": @"Shoulders",
                     @"pull": @"Pull Day",
                     @"push": @"Push Day",
                     @"chestBack": @"Chest & Back",
                     @"chestBiceps": @"Chest & Biceps",
                     @"fullBody": @"Full Body" };
    [self updateInterface];
    self.tableView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0);
    [self loadForm];
    [self.view sendSubviewToBack:self.tableView];
    [Log event:@"EditSmartNamesVC: Presenatation" properties:
       @{@"Source": (self.source == BTEditSmartNamesSourceSettings) ? @"Settings" : @"Workout"}];
}

- (void)updateInterface {
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.backButton setTitle:(self.source == BTEditSmartNamesSourceSettings) ? @"Back" : @"Done"
                     forState:UIControlStateNormal];
    [self.backButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    self.tableView.backgroundColor = [UIColor BTGroupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveSettings];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)questionMarkButtonPressed:(UIButton *)sender {
    [self presentSmartNamesQuestionMarkViewController];
}

- (void)loadForm {
    XLFormDescriptor *form = [XLFormDescriptor formDescriptor];
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    
    section = [XLFormSectionDescriptor formSection];
    if (self.source == BTEditSmartNamesSourceSettings) {
        section.footerTitle = @"Tap any smart name to edit its display name for all workout instances.";
    } else {
        section.footerTitle = @"Tap any smart name to edit its display name for all workout instances. You can disable smart names in settings.";
    }
    [form addFormSection:section];
    for (int i = 0; i < self.settings.smartNicknameDict.count; i++) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:self.sortedKeys[i] rowType:XLFormRowDescriptorTypeText
                                                      title:[NSString stringWithFormat:@"%@", self.altKeys[self.sortedKeys[i]]]];
        row.value = self.settings.smartNicknameDict[self.sortedKeys[i]];
        [section addFormRow:row];
    }
    
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"reset" rowType:XLFormRowDescriptorTypeBTButton title:@"Restore Defaults"];
    row.cellConfig[@"textLabel.textAlignment"] = @(NSTextAlignmentNatural);
    [section addFormRow:row];
    
    for (XLFormSectionDescriptor *section in form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            row.cellConfig[@"backgroundColor"] = UIColor.BTGroupTableViewCellColor;
            row.height = 45;
            if ([row.tag isEqualToString:@"reset"]) continue;
            row.cellConfig[@"textLabel.textColor"] = UIColor.BTBlackColor;
            row.cellConfig[@"textLabel.textAlignment"] = @(NSTextAlignmentNatural);
            row.cellConfig[@"textLabel.font"] = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
            row.cellConfig[@"textField.textColor"] = UIColor.BTBlackColor;
            row.cellConfig[@"textField.textAlignment"] = @(NSTextAlignmentRight);
            row.cellConfig[@"textField.font"] = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
            row.cellConfig[@"tintColor"] = UIColor.BTBlackColor;
            row.cellConfig[@"selectionStyle"] = @(UITableViewCellSelectionStyleNone);
            if (self.selectedSmartName && [row.tag isEqualToString:self.selectedSmartName]) {
                row.cellConfig[@"textLabel.textColor"] = UIColor.BTRedColor;
                row.cellConfig[@"textField.textColor"] = UIColor.BTRedColor;
                row.cellConfig[@"tintColor"] = UIColor.BTRedColor;
            }
        }
    }
    self.form = form;
}

- (void)saveSettings {
    for (XLFormSectionDescriptor *section in self.form.formSections)
        for (XLFormRowDescriptor *row in section.formRows)
            [self.settings setNickname:row.value forSmartName:row.tag];
    [self.context save:nil];
}

#pragma mark - XLForm delegate

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
    if ([formRow.tag isEqualToString:@"reset"]) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Restore Defaults"
                                                                        message:@"Are you sure you want to restore the default smart names? This action can not be undone."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:@"Restore" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Log event:@"EditSmartNamesVC: Reset" properties:nil];
                self.settings.smartNicknames = nil;
                [self.settings smartNicknameDict];
                [self.context save:nil];
                [self loadForm];
            });
        }];
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - view handling

- (void)presentSmartNamesQuestionMarkViewController {
    [Log event:@"EditSmartNamesVC: Present question mark" properties:nil];
    SmartNameQuestionMarkViewController *snqmVC =
        [[SmartNameQuestionMarkViewController alloc] initWithNibName:@"SmartNameQuestionMarkViewController"
                                                              bundle:[NSBundle mainBundle]];
    [self presentViewController:snqmVC withStyle:BTPresentationStyleFromBottom];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
