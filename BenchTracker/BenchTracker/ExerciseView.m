//
//  ExerciseView.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseView.h"
#import "BTExercise+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

#define PICKER_REPS      70  //1-50 by 1, 55-150 by 5
#define PICKER_WEIGHT    130 //0-10 by 1, 12.5, 15-600 by 5
#define PICKER_TIME      48  //1-30 by 1, 35-120 by 5

@interface ExerciseView ()

@property (weak, nonatomic) IBOutlet UIView *deletedView;
@property (weak, nonatomic) IBOutlet UIView *undoDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *previousExerciseButtonCenterConstraint;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *leftTextField;
@property (weak, nonatomic) IBOutlet UITextField *centerTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;

@property (weak, nonatomic) IBOutlet SetCollectionView *collectionView;

@property BTExercise *exercise;

@end

@implementation ExerciseView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor BTPrimaryColor];
    self.nameLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.editButton setImage:[self.editButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]  forState:UIControlStateNormal];
    self.editButton.tintColor = [UIColor BTTextPrimaryColor];
    self.categoryLabel.textColor = [UIColor BTTextPrimaryColor];
    self.textField.backgroundColor = [UIColor BTSecondaryColor];
    self.textField.textColor = [UIColor BTTextPrimaryColor];
    self.leftTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.leftTextField.textColor = [UIColor BTTextPrimaryColor];
    self.centerTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.centerTextField.textColor = [UIColor BTTextPrimaryColor];
    self.rightTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.rightTextField.textColor = [UIColor BTTextPrimaryColor];
    self.deleteButton.backgroundColor = [UIColor BTRedColor];
    for (UIButton *button in @[self.tableShowButton, self.previousExerciseButton]) {
        button.backgroundColor = [UIColor BTSecondaryColor];
        button.layer.cornerRadius = 8;
        button.clipsToBounds = YES;
        [button setImage:[[self translucentImageFromImage:button.imageView.image withAlpha:.8]
                          imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        button.tintColor = [UIColor BTTextPrimaryColor];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.superview.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.superview.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exerciseViewScrollNotification)
                                                 name:@"ExerciseViewScroll"
                                               object:nil];
}

- (void)reloadData {
    self.collectionView.sets = [NSKeyedUnarchiver unarchiveObjectWithData:self.exercise.sets];
}

- (IBAction)editButtonPressed:(UIButton *)sender {
    [self.delegate exerciseViewRequestedEditIteration:self withPoint:sender.center];
    [Log event:@"ExerciseView: Edit iteration" properties:@{@"Exercise": self.exercise.name}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public methods

- (void)updateTitleLabel {
    if (self.exercise.iteration && self.exercise.iteration.length > 0)
         self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", self.exercise.iteration, self.exercise.name];
    else self.nameLabel.text = self.exercise.name;
}

- (void)loadExercise:(BTExercise *)exercise {
    self.previousExerciseButton.hidden = !self.settings.showLastWorkout ||
                                         [exercise.style isEqualToString:STYLE_CUSTOM] ||
                                         ![BTExerciseType typeForExercise:exercise];
    self.previousExerciseButtonCenterConstraint.active = [exercise.style isEqualToString:STYLE_REPS] ||
                                                         [exercise.style isEqualToString:STYLE_TIME];
    self.tableShowButton.hidden = ![exercise.style isEqualToString:STYLE_REPSWEIGHT] || !self.settings.showEquivalencyChart;
    self.editButton.hidden = ([[NSKeyedUnarchiver unarchiveObjectWithData:[BTExerciseType typeForExercise:exercise].iterations] count] == 0);
    self.isDeleted = NO;
    self.deletedView.alpha = 0;
    self.deletedView.userInteractionEnabled = NO;
    self.deleteButton.layer.cornerRadius = 12;
    self.deleteButton.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 16;
    self.contentView.clipsToBounds = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = NO;
    [self loadTextFields];
    self.exercise = exercise;
    [self updateTitleLabel];
    self.categoryLabel.text = exercise.category;
    self.collectionView.setDataSource = self;
    [self reloadData];
    self.collectionView.settings = self.settings;
    if ([self styleIs:STYLE_CUSTOM]) {
        [self showTextField];
        self.textField.text = (self.collectionView.sets.count) ? [self.collectionView.sets.lastObject substringFromIndex:2] : @"";
    }
    else {
        [self showPickerView];
        [self selectAppropriatePickerViewRows];
    }
}

- (void)setIteration:(NSString *)iteration {
    self.exercise.iteration = iteration;
    [self updateTitleLabel];
}

- (BTExercise *)getExercise {
    self.exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:self.collectionView.sets];
    [self.exercise calculateOneRM];
    [self.exercise calculateVolume];
    return self.exercise;
}

#pragma mark - private methods

- (void)selectAppropriatePickerViewRows {
    NSArray <NSString *> *set = [self.collectionView.sets.lastObject componentsSeparatedByString:@" "];
    NSArray <NSString *> *prevInstanceSets = [NSKeyedUnarchiver unarchiveObjectWithData:[self.exercise lastInstance].sets];
    if (!set && prevInstanceSets) set = [prevInstanceSets.firstObject componentsSeparatedByString:@" "];
    if ([self styleIs:STYLE_REPSWEIGHT]) {
        self.centerTextField.alpha = 0;
        self.centerTextField.userInteractionEnabled = NO;
        self.leftTextField.text = @"10";
        self.rightTextField.text = @"40";
        if (set) {
            [self selectRowClosestTo:set[0].floatValue inComponent:0];
            [self selectRowClosestTo:set[1].floatValue inComponent:1];
            self.leftTextField.text = set[0];
            self.rightTextField.text = set[1];
        }
    }
    else if ([self styleIs:STYLE_REPS]) {
        self.leftTextField.alpha = 0;
        self.leftTextField.userInteractionEnabled = NO;
        self.rightTextField.alpha = 0;
        self.rightTextField.userInteractionEnabled = NO;
        self.centerTextField.text = @"10";
        if (set) {
            [self selectRowClosestTo:set[0].floatValue inComponent:0];
            self.centerTextField.text = set[0];
        }
    }
    else if ([self styleIs:STYLE_TIME]) {
        self.leftTextField.alpha = 0;
        self.leftTextField.userInteractionEnabled = NO;
        self.rightTextField.alpha = 0;
        self.rightTextField.userInteractionEnabled = NO;
        self.centerTextField.text = @"30";
        if (set) {
            [self selectRowClosestTo:set[1].floatValue inComponent:0];
            self.centerTextField.text = set[1];
        }
    }
    else { //TIME_WEIGHT
        self.centerTextField.alpha = 0;
        self.centerTextField.userInteractionEnabled = NO;
        self.leftTextField.text = @"30";
        self.rightTextField.text = @"40";
        if (set) {
            [self selectRowClosestTo:set[1].floatValue inComponent:0];
            [self selectRowClosestTo:set[2].floatValue inComponent:1];
            self.leftTextField.text = set[1];
            self.rightTextField.text = set[2];
        }
    }
    if (!set) {                                                                                 //Reps, Time
        [self.pickerView selectRow:([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_REPS]) ? 9 : 29 inComponent:0 animated:NO];
        if (self.pickerView.numberOfComponents == 2) [self.pickerView selectRow: 17 inComponent:1 animated:NO];
    }
}

- (void)selectRowClosestTo:(float)value inComponent:(int)component {
    if (component == 1) { //weight
        if (value < 11) [self.pickerView selectRow:MAX(0, (int)value) inComponent:1 animated:YES]; //0-10
        else if (value < 15) [self.pickerView selectRow:11 inComponent:1 animated:YES]; //12.5
        else [self.pickerView selectRow:MIN(129, ((int)value)/5+9) inComponent:1 animated:YES]; //15-600+ (12)
    }
    else if ([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_REPS]) { //reps
        if (value < 51) [self.pickerView selectRow:MAX(0, (int)value-1) inComponent:0 animated:YES];
        else [self.pickerView selectRow:MIN(69, ((int)value)/5+39) inComponent:0 animated:YES];
    }
    else { //time
        if (value < 31) [self.pickerView selectRow:MAX(0, (int)value-1) inComponent:0 animated:YES];
        else [self.pickerView selectRow:MIN(47, ((int)value)/5+23) inComponent:0 animated:YES];
    }
}

- (void)exerciseViewScrollNotification {
    [self resignFirstResponderAllTextFields];
}

- (void)loadTextFields {
    for (UITextField *tF in @[self.textField, self.leftTextField, self.centerTextField, self.rightTextField]) {
        tF.delegate = self;
        tF.layer.cornerRadius = 8;
        tF.clipsToBounds = YES;
    }
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter a custom set" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.5]}];
}

- (IBAction)deleteButtonPressed:(UIButton *)sender {
    [Log event:@"ExerciseView: Delete exercise" properties:@{@"Deleted": @"True",
                                                             @"Exercise": self.exercise.name}];
    [self resignFirstResponderAllTextFields];
    self.isDeleted = YES;
    self.deletedView.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
       self.deletedView.alpha = 1;
    }];
}

- (IBAction)previousExerciseButtonPressed:(UIButton *)sender {
    [Log event:@"ExerciseView: Show analytics" properties:@{@"Exercise": self.exercise.name}];
    [self.delegate exerciseViewRequestedShowExerciseDetails:self];
}

- (IBAction)tableShowButtonPressed:(UIButton *)sender {
    [Log event:@"ExerciseView: Show equivalency" properties:@{@"Exercise": self.exercise.name}];
    [self.delegate exerciseViewRequestedShowTable:self];
}

- (IBAction)undoDeleteButtonPressed:(UIButton *)sender {
    [Log event:@"ExerciseView: Delete exercise" properties:@{@"Deleted": @"False",
                                                             @"Exercise": self.exercise.name}];
    self.isDeleted = NO;
    self.deletedView.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3 animations:^{
        self.deletedView.alpha = 0;
    } completion:^(BOOL finished) {
        self.deletedView.userInteractionEnabled = NO;
    }];
}

- (void)showTextField {
    self.pickerView.alpha = 0;
    self.pickerView.userInteractionEnabled = NO;
    for (UITextField *tF in @[self.leftTextField, self.centerTextField, self.rightTextField]) {
        tF.alpha = 0;
        tF.userInteractionEnabled = NO;
    }
}

- (void)showPickerView {
    self.textField.alpha = 0;
    self.textField.userInteractionEnabled = NO;
}

- (BOOL)styleIs:(NSString *)string {
    return [self.exercise.style isEqualToString:string];
}

#pragma mark - pickerView dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if ([self styleIs:STYLE_TIME] || [self styleIs:STYLE_REPS]) return 1;
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([self styleIs:STYLE_REPSWEIGHT])
        return (component == 0) ? PICKER_REPS : PICKER_WEIGHT;
    if ([self styleIs:STYLE_REPS]) return PICKER_REPS;
    if ([self styleIs:STYLE_TIME]) return PICKER_TIME;
    if ([self styleIs:STYLE_TIMEWEIGHT])
        return (component == 0) ? PICKER_TIME : PICKER_WEIGHT;
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 20;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel*)view;
    if (!label){
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        label.textColor = [UIColor BTTextPrimaryColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    if (component == 1) { //weight
        NSInteger num = (row < 12) ? row : (row-11)*5+10;
        label.text = [NSString stringWithFormat:@"%ld %@", (long)num, (num == 0) ? @"(bodyweight)" : self.settings.weightSuffix];
        label.tag = num;
        if (row == 11) label.text = [NSString stringWithFormat:@"12.5 %@", self.settings.weightSuffix];
    }
    else if ([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_REPS]) { //reps
        NSInteger num = (row < 50) ? row+1 : (row-49)*5+50;
        label.text = [NSString stringWithFormat:@"%ld %@", (long)num, (num == 1) ? @"rep" : @"reps"];
        label.tag = num;
    }
    else { //time
        NSInteger num = (row < 30) ? row+1 : (row-29)*5+30;
        label.text = [NSString stringWithFormat:@"%ld %@", (long)num, (num == 1) ? @"sec" : @"secs"];
        label.tag = num;
    }
    return label;
}

#pragma mark - pickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 1) { //right
        NSInteger weight = [pickerView viewForRow:row forComponent:component].tag;
        self.rightTextField.text = (weight != 11) ? [NSString stringWithFormat:@"%ld",(long)weight] : @"12.5";
    }
    else if (pickerView.numberOfComponents == 2) //left
        self.leftTextField.text = [NSString stringWithFormat:@"%ld",(long)[pickerView viewForRow:row forComponent:component].tag];
    else //center
        self.centerTextField.text = [NSString stringWithFormat:@"%ld",(long)[pickerView viewForRow:row forComponent:component].tag];
}

#pragma mark - setCollectionView dataSource

- (NSString *)setToAddForSetCollectionView:(SetCollectionView *)collectionView {
    [self resignFirstResponderAllTextFields];
    [self.delegate exerciseViewDidAddSet:self];
    float val1 = (self.leftTextField.text.length) ? self.leftTextField.text.floatValue : -1;
    float val2 = (self.centerTextField.text.length) ? self.centerTextField.text.floatValue : -1;
    float val3 = (self.rightTextField.text.length) ? self.rightTextField.text.floatValue : -1;
    if (self.leftTextField.text.length) [self selectRowClosestTo:self.leftTextField.text.floatValue inComponent:0];
    if (self.centerTextField.text.length) [self selectRowClosestTo:self.centerTextField.text.floatValue inComponent:0];
    if (self.rightTextField.text.length) [self selectRowClosestTo:self.rightTextField.text.floatValue inComponent:1];
    NSString *result;
    if ([self styleIs:STYLE_REPSWEIGHT]) {
        int reps = (val1 >= 0) ? val1 :
        (int)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0].tag;
        float weight = (val3 >= 0) ? val3 :
        (float)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1].tag;
        if (weight == 11)   result = [NSString stringWithFormat:@"%d 12.5",reps];
        else                result = [NSString stringWithFormat:@"%d %.0f",reps,weight];
    }
    else if ([self styleIs:STYLE_REPS]) {
        int reps = (val2 >= 0) ? val2 :
        (int)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0].tag;
        result = [NSString stringWithFormat:@"%d",reps];
    }
    else if ([self styleIs:STYLE_TIME]) {
        int time = (val2 >= 0) ? val2 :
        (int)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0].tag;
        result = [NSString stringWithFormat:@"s %d",time];
    }
    else if ([self styleIs:STYLE_TIMEWEIGHT]) {
        int time = (val1 >= 0) ? val1 :
        (int)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0].tag;
        float weight = (val3 >= 0) ? val3 :
        (float)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1].tag;
        result = [NSString stringWithFormat:@"s %d %.0f",time,weight];
    }
    else result = [NSString stringWithFormat:@"~ %@",self.textField.text];
    return result;
}

#pragma mark - textField delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.leftTextField) [self selectRowClosestTo:self.leftTextField.text.floatValue inComponent:0];
    else if (textField == self.rightTextField) [self selectRowClosestTo:self.rightTextField.text.floatValue inComponent:1];
    else if (textField == self.centerTextField) [self selectRowClosestTo:self.centerTextField.text.floatValue inComponent:0];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *rStr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (textField == self.textField && rStr.length <= 30) return YES;
    if (textField == self.rightTextField) {
        if ([rStr containsString:@"."] && rStr.length <= 5) return YES;
        else if (rStr.length <= 4) return YES;
    }
    if (rStr.length <= 3) return YES;
    return NO;
}

- (void)resignFirstResponderAllTextFields {
    for (UITextField *tF in @[self.textField, self.leftTextField, self.centerTextField, self.rightTextField])
      if (tF.isFirstResponder) [tF resignFirstResponder];
}

- (BOOL)hasFirstResponder {
    for (UITextField *tF in @[self.textField, self.leftTextField, self.centerTextField, self.rightTextField])
        if (tF.isFirstResponder) return YES;
    return NO;
}

- (UIImage *)translucentImageFromImage:(UIImage *)image withAlpha:(CGFloat)alpha {
    CGRect rect = CGRectZero;
    rect.size = image.size;
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:rect blendMode:kCGBlendModeScreen alpha:alpha];
    UIImage * translucentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return translucentImage;
}

#pragma mark - keyboard handling

- (void)keyboardWillShow:(NSNotification *)n {
    if ([self hasFirstResponder]) {
        UIScrollView *scrollView = (UIScrollView *)self.superview.superview;
        float keyboardHeight = [[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [scrollView scrollRectToVisible:
            CGRectMake(0, self.frame.origin.y, 1, self.contentView.frame.size.height+keyboardHeight+30) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)n {

}

@end
