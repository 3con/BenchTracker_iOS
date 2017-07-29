//
//  EEDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EEDetailViewController.h"
#import "BTButtonFormCell.h"
#import "BTExerciseTypeStyleTransformer.h"

@interface EEDetailViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@end

@implementation EEDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    [self loadForm];
    [self.view sendSubviewToBack:self.tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(72, 0, 0, 0);
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (XLFormSectionDescriptor *section in self.form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            if (row.tag && ![row.tag isEqualToString:@""])
                [result setObject:(row.value ?: [NSNull null]) forKey:row.tag];
        }
    }
    //self.settings.weightInLbs = ![result[@"weightInKg"] boolValue];
    [self.delegate editExerciseDetailViewControllerWillDismiss:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadForm {
    XLFormDescriptor *form;
    XLFormSectionDescriptor *section;
    XLFormRowDescriptor *row;
    form = [XLFormDescriptor formDescriptor];
    
    // Section 1: Name
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"name" rowType:XLFormRowDescriptorTypeText title:@"Name"];
    row.value = (self.type) ? self.type.name : @"";
    [row.cellConfig setObject:[UIColor BTBlackColor] forKey:@"textField.textColor"];
    [section addFormRow:row];
    
    // Section 2: Category
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"The primary style / muscle this exercise works.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"category" rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Category"];
    row.value = (self.type) ? self.type.category : @"Cardio";
    row.selectorOptions = @[@"Abs / Core", @"Back", @"Biceps", @"Cardio", @"Chest", @"Legs", @"Olympic", @"Shoulders", @"Triceps"];
    [section addFormRow:row];
    
    // Section 3: Style
    section = [XLFormSectionDescriptor formSection];
    section.footerTitle = @"How you will record this exercise during a workout.";
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"style" rowType:XLFormRowDescriptorTypeSelectorPickerView title:@"Set Format"];
    row.value = (self.type) ? self.type.style : @"repsWeight";
    row.selectorOptions = @[@"repsWeight", @"reps", @"time", @"timeWeight", @"custom"];
    row.valueTransformer = [BTExerciseTypeStyleTransformer class];
    [section addFormRow:row];
    
    // Section 4: Variations
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Variations"
                                             sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert |
                                                            XLFormSectionOptionCanDelete
                                          sectionInsertMode:XLFormSectionInsertModeButton];
    section.footerTitle = @"Specify the possible variations in which the exercise can be performed to track them individually.";
    section.multivaluedTag = @"variations";
    section.multivaluedAddButton.title = @"Add a variation";
    [section.multivaluedRowTemplate.cellConfig setObject:[UIColor BTBlackColor] forKey:@"textLabel.textColor"];
    if (self.type) {
        for (NSString *varitaion in [NSKeyedUnarchiver unarchiveObjectWithData:self.type.iterations]) {
            row = [XLFormRowDescriptor formRowDescriptorWithTag:nil rowType:XLFormRowDescriptorTypeText title:nil];
            [[row cellConfig] setObject:@"Varitaion name" forKey:@"textField.placeholder"];
            row.value = varitaion;
            [section addFormRow:row];
        }
    }
    [form addFormSection:section];
    
    // Section 5: Delete
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"delete" rowType:XLFormRowDescriptorTypeBTButton title:@"Delete Exercise"];
    [row.cellConfig setObject:@(NSTextAlignmentNatural) forKey:@"textLabel.textAlignment"];
    row.action.formBlock = ^(XLFormRowDescriptor *sender){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Exercise"
                                                                        message:@"Are you sure you want to delete this exercise? You will no longer be able to see your progress for this exercise. This action can be undone but it is not easy."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    };
    [section addFormRow:row];
    
    for (XLFormSectionDescriptor *section in form.formSections) {
        for (XLFormRowDescriptor *row in section.formRows) {
            [row.cellConfig setObject:[UIColor BTBlackColor] forKey:@"textLabel.textColor"];
            [row.cellConfig setObject:@(UITableViewCellSelectionStyleNone) forKey:@"selectionStyle"];
            [row.cellConfig setObject:[UIColor BTSecondaryColor] forKey:@"tintColor"];
    }   }
    self.form = form;
}

#pragma mark - XLForm delegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)formRow oldValue:(id)oldValue newValue:(id)newValue {
    
}

- (void)didSelectFormRow:(XLFormRowDescriptor *)formRow {
   
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
