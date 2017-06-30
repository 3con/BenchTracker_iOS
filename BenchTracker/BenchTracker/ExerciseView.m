//
//  ExerciseView.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseView.h"
#import "BTExercise+CoreDataClass.h"
#import "SetCollectionViewCell.h"
#import "SetFlowLayout.h"

#define STYLE_REPSWEIGHT @"repsWeight"
#define STYLE_REPS       @"reps"
#define STYLE_TIMEWEIGHT @"timeWeight"
#define STYLE_TIME       @"time"
#define STYLE_CUSTOM     @"custom"

#define PICKER_REPS      70  //1-50 by 1, 55-150 by 5
#define PICKER_WEIGHT    131 //0-10 by 1, 12.5, 15-600 by 5
#define PICKER_TIME      48  //1-30 by 1, 35-120 by 5

@interface ExerciseView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property BTExercise *exercise;

@property (nonatomic) NSMutableArray <NSString *> *tempSets;

@end

@implementation ExerciseView

- (void)loadExercise: (BTExercise *)exercise {
    self.contentView.layer.cornerRadius = 12;
    self.contentView.clipsToBounds = YES;
    self.textField.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    SetFlowLayout *flowLayout = [[SetFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(70, 45);
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SetCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"ACell"];
    self.exercise = exercise;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", exercise.iteration, exercise.name];
    self.categoryLabel.text = exercise.category;
    self.tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
    if ([self styleIs:STYLE_CUSTOM]) [self loadTextField];
    else [self loadPickerView];                                                             //Reps, Time
    [self.pickerView selectRow:([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_REPS]) ? 9 : 29 inComponent:0 animated:NO];
    if (self.pickerView.numberOfComponents == 2) [self.pickerView selectRow: 17 inComponent:1 animated:NO];
    [self.collectionView reloadData];                                     //Weight
}

- (BTExercise *)getExercise {
    self.exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:self.tempSets];
    return self.exercise;
}

- (void)loadTextField {
    self.pickerView.alpha = 0;
    self.pickerView.userInteractionEnabled = NO;
}

- (void)loadPickerView {
    self.textField.alpha = 0;
    self.textField.userInteractionEnabled = NO;
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
    if ([self styleIs:STYLE_REPS] || ([self styleIs:STYLE_REPSWEIGHT] && component == 0)) {             //REPS
        NSInteger num = (row < 50) ? row+1 : (row-49)*5+50;
        label.text = [NSString stringWithFormat:@"%ld %@", num, (num == 1) ? @"rep" : @"reps"];
        label.tag = num;
    }
    else if (([self styleIs:STYLE_REPSWEIGHT] || [self styleIs:STYLE_TIMEWEIGHT]) && component == 1) {  //WEIGHT
        NSInteger num = (row < 12) ? row : (row-11)*5+10;
        label.text = [NSString stringWithFormat:@"%ld %@", num, (num == 0) ? @"(bodyweight)" : (num == 1) ? @"lb" : @"lbs"];
        label.tag = num;
        if (row == 11) label.text = @"12.5 lbs";
    }
    else {                                                                                         //TIME
        NSInteger num = (row < 30) ? row+1 : (row-29)*5+30;
        label.text = [NSString stringWithFormat:@"%ld %@", num, (num == 1) ? @"sec" : @"secs"];
        label.tag = num;
    }
    return label;
}

#pragma mark - pickerView delegate

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
        cell.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:128/255.0 alpha:1];
        cell.layer.cornerRadius = 12;
        cell.clipsToBounds = YES;
        if (cell.subviews.count == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 70, 45)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor colorWithRed:95/255.0 green:100/255.0 blue:255/255.0 alpha:1];
            label.text = @"+";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];
            [cell addSubview:label];
        }
        return cell;
    }
    SetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell loadSetWithString:self.tempSets[self.tempSets.count-(indexPath.row-1)-1]];
    return cell;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { //add set
        if (self.tempSets.count < 12) {
            [self.collectionView performBatchUpdates:^{
                NSString *result;
                if ([self styleIs:STYLE_REPSWEIGHT]) {
                    int reps = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0] tag];
                    int weight = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1] tag];
                    if (weight == 11)   result = [NSString stringWithFormat:@"%d 12.5",reps];
                    else                result = [NSString stringWithFormat:@"%d %d",reps,weight];
                }
                else if ([self styleIs:STYLE_REPS]) {
                    int reps = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0] tag];
                    result = [NSString stringWithFormat:@"%d",reps];
                }
                else if ([self styleIs:STYLE_TIME]) {
                    int time = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0] tag];
                    result = [NSString stringWithFormat:@"s %d",time];
                }
                else if ([self styleIs:STYLE_TIMEWEIGHT]) {
                    int time = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:0] forComponent:0] tag];
                    int weight = (int)[(UILabel *)[self.pickerView viewForRow:[self.pickerView selectedRowInComponent:1] forComponent:1] tag];
                    if (weight == 11)   result = [NSString stringWithFormat:@"s %d 12.5",time];
                    else                result = [NSString stringWithFormat:@"s %d %d",time,weight];
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
                            } completion:^(BOOL finished) {
                                
                            }];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)styleIs:(NSString *)string {
    return [self.exercise.style isEqualToString:string];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
