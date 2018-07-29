//
//  AdjustTimesViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/29/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "AdjustTimesViewController.h"
#import "BTWorkout+CoreDataClass.h"

@interface AdjustTimesViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *startTimePickerView;

@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *durationPickerView;

@property (weak, nonatomic) IBOutlet UILabel *autoTextLabel;
@property (weak, nonatomic) IBOutlet UISwitch *autoSwitchView;


@end

@implementation AdjustTimesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    self.startTimePickerView.delegate = self;
    self.startTimePickerView.dataSource = self;
    self.durationPickerView.delegate = self;
    self.durationPickerView.dataSource = self;
    [self selectStartDate];
    [self selectDuration];
    [self updateInterface];
    [self updateAutoDurationState];
    self.contentView.layer.cornerRadius = 25;
    self.contentView.clipsToBounds = YES;
    self.doneButton.layer.cornerRadius = 12;
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.doneButton.alpha = 0.0;
}

- (void)updateInterface {
    self.contentView.backgroundColor = UIColor.BTVibrantColors[3];
    self.backgroundView.backgroundColor = UIColor.BTModalViewBackgroundColor;
    self.titleLabel.textColor = UIColor.BTTextPrimaryColor;
    self.startTimeLabel.textColor = UIColor.BTTextPrimaryColor;
    self.durationLabel.textColor = UIColor.BTTextPrimaryColor;
    self.autoTextLabel.textColor = UIColor.BTTextPrimaryColor;
    self.doneButton.backgroundColor = UIColor.BTButtonPrimaryColor;
    self.autoSwitchView.onTintColor = UIColor.BTTextPrimaryColor;
    [self.doneButton setTitleColor:UIColor.BTButtonTextPrimaryColor forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate adjustTimesViewControllerWillDismiss:self];
    [self animateOut];
}

- (IBAction)autoSwitchPressed:(UISwitch *)sender {
    [self updateAutoDurationState];
}

- (void)updateAutoDurationState {
    self.durationLabel.text = (self.autoSwitchView.isOn) ? [NSString stringWithFormat:@"Duration: %lld min", self.workout.duration/60] : @"Duration:";
    self.contentViewHeightConstraint.constant = (self.autoSwitchView.isOn) ? 240 : 320;
    [UIView animateWithDuration:.25 animations:^{
        self.durationPickerView.alpha = !self.autoSwitchView.isOn;
        self.autoTextLabel.alpha = self.autoSwitchView.isOn;
        [self.view layoutIfNeeded];
    }];
}

- (void)selectStartDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *componenets = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.workout.date];
    NSInteger interval = [[self normalizedDateForDate:NSDate.date] timeIntervalSinceDate:[self normalizedDateForDate:self.workout.date]];
    [self.startTimePickerView selectRow:364 - interval/(24*60*60) inComponent:0 animated:NO];
    [self.startTimePickerView selectRow:(componenets.hour == 0) ? 11 : (componenets.hour - 1) % 12 inComponent:1 animated:NO];
    [self.startTimePickerView selectRow:componenets.minute inComponent:2 animated:NO];
    [self.startTimePickerView selectRow:componenets.hour / 12 == 1 inComponent:3 animated:NO];
}

- (void)selectDuration {
    [self.durationPickerView selectRow:self.workout.duration/60 inComponent:0 animated:NO];
}

#pragma mark - pickerView dataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return (pickerView == self.startTimePickerView) ? 4 : 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.startTimePickerView) {
        if (component == 0) return 365; //DATE
        else if (component == 1) return 12; // HR
        else if (component == 2) return 60; // MIN
        else return 2; // AM / PM
    }
    return 181;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (pickerView == self.startTimePickerView) {
        if (component == 0) return 120; //DATE
        else if (component == 1) return 40; // HR
        else if (component == 2) return 40; // MIN
        else return 40; // AM / PM
    }
    return 240;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 25;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel*)view;
    if (!label) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        label.textColor = UIColor.BTTextPrimaryColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    if (pickerView == self.startTimePickerView) {
        if (component == 0) { // day
            NSDate *date = [NSDate.date dateByAddingTimeInterval:-24*60*60*(364-row)];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"E MMM d"];
            label.text = (row == 364) ? @"Today" : [formatter stringFromDate:date];
        }
        else if (component == 1) label.text = [NSString stringWithFormat:@"%d", (int)row + 1]; // hour
        else if (component == 2) label.text = [NSString stringWithFormat:@"%02d", (int)row]; // minute
        else label.text = (row) ? @"PM" : @"AM"; // AM / PM
    }
    else label.text = [NSString stringWithFormat:@"%d min", (int)row]; // duration
    return label;
}

#pragma mark - pickerView delegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.startTimePickerView) self.workout.date = [self selectedDate]; // date
    else self.workout.duration = row * 60; // duration
}

- (NSDate *)selectedDate {
    NSDate *date = [NSDate.date dateByAddingTimeInterval:-24*60*60*(364-[self.startTimePickerView selectedRowInComponent:0])];
    NSDate *day = [self normalizedDateForDate:date];
    NSInteger rawHour = [self.startTimePickerView selectedRowInComponent:1];
    day = [day dateByAddingTimeInterval:((rawHour == 11) ? 0 : rawHour + 1)*60*60];
    day = [day dateByAddingTimeInterval:[self.startTimePickerView selectedRowInComponent:2]*60];
    day = [day dateByAddingTimeInterval:[self.startTimePickerView selectedRowInComponent:3]*60*60*12];
    return day;
}

- (NSDate *)normalizedDateForDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [gregorian dateFromComponents:
            [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date]];
}

#pragma mark - animation

- (void)animateIn {
    self.backgroundView.alpha = 0.0;
    self.contentView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.contentView.alpha = 0.5;
    self.contentView.center = self.point;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.center = CGPointMake(self.view.center.x, self.view.center.y-35);
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
        self.doneButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        self.doneButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
