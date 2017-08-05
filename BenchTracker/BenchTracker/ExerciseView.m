//
//  ExerciseView.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseView.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "SetCollectionViewCell.h"
#import "SetFlowLayout.h"

#define PICKER_REPS      70  //1-50 by 1, 55-150 by 5
#define PICKER_WEIGHT    130 //0-10 by 1, 12.5, 15-600 by 5
#define PICKER_TIME      48  //1-30 by 1, 35-120 by 5

@interface ExerciseView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIView *deletedView;
@property (weak, nonatomic) IBOutlet UIView *undoDeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UIButton *tableShowButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *leftTextField;
@property (weak, nonatomic) IBOutlet UITextField *centerTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property BTExercise *exercise;

@property (nonatomic) NSMutableArray <NSString *> *tempSets;

@end

@implementation ExerciseView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor BTPrimaryColor];
    self.textField.backgroundColor = [UIColor BTSecondaryColor];
    self.leftTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.centerTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.rightTextField.backgroundColor = [UIColor BTSecondaryColor];
    self.deleteButton.backgroundColor = [UIColor BTRedColor];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - public methods

- (void)loadExercise:(BTExercise *)exercise {
    if (![exercise.style isEqualToString:STYLE_REPSWEIGHT]) {
        self.tableShowButton.alpha = 0;
        self.tableShowButton.userInteractionEnabled = NO;
    }
    self.isDeleted = NO;
    self.deletedView.alpha = 0;
    self.deletedView.userInteractionEnabled = NO;
    self.deleteButton.layer.cornerRadius = 12;
    self.deleteButton.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 12;
    self.contentView.clipsToBounds = YES;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.showsSelectionIndicator = NO;
    [self loadTextFields];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    SetFlowLayout *flowLayout = [[SetFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(70, 45);
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(7, 10, 8, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SetCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ACell"];
    self.exercise = exercise;
    if (exercise.iteration) self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", exercise.iteration, exercise.name];
    else                    self.nameLabel.text = exercise.name;
    self.categoryLabel.text = exercise.category;
    self.tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
    if ([self styleIs:STYLE_CUSTOM]) {
        [self showTextField];
        self.textField.text = (self.tempSets.count) ? [self.tempSets.lastObject substringFromIndex:2] : @"";
    }
    else {
        [self showPickerView];
        [self selectAppropriatePickerViewRows];
    }
    [self.collectionView reloadData];
}

- (BTExercise *)getExercise {
    self.exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:self.tempSets];
    return self.exercise;
}

#pragma mark - private methods

- (void)selectAppropriatePickerViewRows {
    NSArray <NSString *> *set = [self.tempSets.lastObject componentsSeparatedByString:@" "];
    if ([self styleIs:STYLE_REPSWEIGHT]) {
        self.centerTextField.alpha = 0;
        self.centerTextField.userInteractionEnabled = NO;
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
        if (set) {
            [self selectRowClosestTo:set[1].floatValue inComponent:0];
            self.centerTextField.text = set[1];
        }
    }
    else { //TIME_WEIGHT
        self.centerTextField.alpha = 0;
        self.centerTextField.userInteractionEnabled = NO;
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
    [self resignFirstResponderAllTextFields];
    self.isDeleted = YES;
    self.deletedView.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3 animations:^{
       self.deletedView.alpha = 1;
    }];
}

- (IBAction)tableShowButtonPressed:(UIButton *)sender {
    [self.delegate exerciseViewRequestedShowTable:self];
}

- (IBAction)undoDeleteButtonPressed:(UIButton *)sender {
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
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
    }
    if (component == 1) { //weight
        NSInteger num = (row < 12) ? row : (row-11)*5+10;
        label.text = [NSString stringWithFormat:@"%ld %@", num, (num == 0) ? @"(bodyweight)" : self.settings.weightSuffix];
        label.tag = num;
        if (row == 11) label.text = [NSString stringWithFormat:@"12.5 %@", self.settings.weightSuffix];
    }
    else if ([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_REPS]) { //reps
        NSInteger num = (row < 50) ? row+1 : (row-49)*5+50;
        label.text = [NSString stringWithFormat:@"%ld %@", num, (num == 1) ? @"rep" : @"reps"];
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
    if (component == 1) {//right
        NSInteger weight = [pickerView viewForRow:row forComponent:component].tag;
        self.rightTextField.text = (weight != 11) ? [NSString stringWithFormat:@"%ld",(long)weight] : @"12.5";
    }
    else if (pickerView.numberOfComponents == 2) //left
        self.leftTextField.text = [NSString stringWithFormat:@"%ld",[pickerView viewForRow:row forComponent:component].tag];
    else //center
        self.centerTextField.text = [NSString stringWithFormat:@"%ld",[pickerView viewForRow:row forComponent:component].tag];
}

#pragma mark - collectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tempSets.count+1;
}

- (CGSize)sizeForItemWithColumnIndex:(NSUInteger)columnIndex {
    return CGSizeMake(70, 45);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { //first cell: add set
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ACell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor BTSecondaryColor];
        cell.layer.cornerRadius = 12;
        cell.clipsToBounds = YES;
        if (cell.subviews.count == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 70, 45)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [self lighterColorForColor:[UIColor BTSecondaryColor]];
            label.text = @"+";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];
            [cell addSubview:label];
        }
        return cell;
    }
    SetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell loadSetWithString:self.tempSets[self.tempSets.count-(indexPath.row-1)-1] weightSuffix:self.settings.weightSuffix];
    return cell;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self resignFirstResponderAllTextFields];
    if (indexPath.row == 0) { //add set
        if (self.tempSets.count < 12) {
            [self.collectionView performBatchUpdates:^{
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
                    else                result = [NSString stringWithFormat:@"%d %.1f",reps,weight];
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
                    result = [NSString stringWithFormat:@"s %d %.1f",time,weight];
                }
                else result = [NSString stringWithFormat:@"~ %@",self.textField.text];
                [self.tempSets addObject:result];
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
            } completion:nil];
        }
        else {
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            UILabel *label = cell.subviews[1];
            [UIView animateWithDuration:.2 animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                label.text = @"x";
                [UIView animateWithDuration:.2 animations:^{
                    label.alpha = 1;
                } completion:^(BOOL finished) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [UIView animateWithDuration:.2 animations:^{
                            label.alpha = 0;
                        } completion:^(BOOL finished) {
                            label.text = @"+";
                            [UIView animateWithDuration:.2 animations:^{
                                label.alpha = 1;
                            } completion:nil];
                        }];
                    });
                }];
            }];
        }
    }
    else { //delete set
        [(SetCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath] performDeleteAnimationWithDuration:.4];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,.2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{
                [self.tempSets removeObjectAtIndex:self.tempSets.count-(indexPath.row-1)-1];
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:nil];
        });
    }
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

#pragma mark - color methods

- (UIColor *)lighterColorForColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b*2.5, 1.0) alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:b*0.8 alpha:a];
    return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
