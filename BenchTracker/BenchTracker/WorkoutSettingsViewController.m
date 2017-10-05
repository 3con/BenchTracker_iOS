//
//  WorkoutSettingsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutSettingsViewController.h"
#import "BTAchievement+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "BTPDFGenerator.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "MMQRCodeMakerUtil.h"

@interface WorkoutSettingsViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (weak, nonatomic) IBOutlet UIButton *templateButton;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@end

@implementation WorkoutSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    self.contentView.backgroundColor = [UIColor BTPrimaryColor];
    for (UIButton *button in @[self.qrButton, self.printButton, self.templateButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor BTSecondaryColor];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    self.contentView.layer.cornerRadius = 12;
    self.contentView.clipsToBounds = YES;
    self.doneButton.layer.cornerRadius = 12;
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.doneButton.alpha = 0.0;
    [self updateTemplateButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInfo];
}

- (void)updateInfo {
    NSString *name = (self.workout.name.length < 20) ?
    self.workout.name : [NSString stringWithFormat:@"%@...",[self.workout.name substringToIndex:17]];
    NSDateFormatter *yFormatter = [[NSDateFormatter alloc] init];
    [yFormatter setDateFormat:@"M/d/yy"];
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setDateFormat:@"h:mma"];
    NSString *str = [NSString stringWithFormat:@"%@ (%@)\nExercises: %lld, Sets: %lld\nVolume: %lld %@\nStart: %@, Duration: %lld min",
                     name, [yFormatter stringFromDate:self.workout.date], self.workout.numExercises, self.workout.numSets, self.workout.volume,
                     self.settings.weightSuffix, [[dFormatter stringFromDate:self.workout.date] lowercaseString], self.workout.duration/60];
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:str];
    //[aStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,5)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 22;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    [aStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, aStr.length)];
    self.detailLabel.attributedText = aStr;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self animateOut];
}

- (IBAction)qrButtonPressed:(UIButton *)sender {
    [self presentQRDisplayViewControllerWithPoint:[self.view convertPoint:sender.center fromView:self.contentView]];
}

- (IBAction)printButtonPressed:(UIButton *)sender {
    NSString *path = [BTPDFGenerator generatePDFWithWorkouts:@[self.workout]];
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    printController.delegate = self;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = self.workout.name;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printController.printInfo = printInfo;
    printController.printingItem = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){
        if (!completed && error) NSLog(@"PDF print failed due to error in domain %@, error code %ld", error.domain, (long)error.code);
        if (completed) [BTAchievement markAchievementComplete:ACHIEVEMENT_PRINT animated:YES];
    }];
}

- (IBAction)templateButtonPressed:(UIButton *)sender {
    if ([BTWorkoutTemplate templateExistsForWorkout:self.workout])
         [BTWorkoutTemplate removeWorkoutFromTemplateList:self.workout];
    else [BTWorkoutTemplate saveWorkoutToTemplateList:self.workout];
    [self updateTemplateButton];
}

- (void)updateTemplateButton {
    [UIView animateWithDuration:.1 animations:^{
        self.templateButton.alpha = 0;
    } completion:^(BOOL finished) {
        if (![BTWorkoutTemplate templateExistsForWorkout:self.workout]) {
            [self.templateButton setTitle:@"Add to templates" forState:UIControlStateNormal];
            [self.templateButton setImage:[UIImage imageNamed:@"TemplateAdd"] forState:UIControlStateNormal];
        }
        else {
            [self.templateButton setTitle:@"Remove from templates" forState:UIControlStateNormal];
            [self.templateButton setImage:[UIImage imageNamed:@"TemplateDelete"] forState:UIControlStateNormal];
        }
        [UIView animateWithDuration:.1 animations:^{
            self.templateButton.alpha = 1;
        }];
    }];
}

- (IBAction)detailLabelTapped:(UITapGestureRecognizer *)sender {
    [self durationButtonPressed:nil];
}

- (IBAction)durationButtonPressed:(UIButton *)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Manual Duration"
                                                                              message: @"Please enter your workout duration in minutes. Be aware that if you continue adding sets workout duration will still increment."
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"%lld mins", self.workout.duration/60];
        textField.textColor = [UIColor BTBlackColor];
        textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *durationField = alertController.textFields.firstObject;
        if (durationField.text && durationField.text.length > 0)
            self.workout.duration = durationField.text.integerValue * 60;
        [self.context save:nil];
        [self updateInfo];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - printInteractionVC delegate

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    
}

#pragma mark - qrView delegate

- (void)QRDisplayViewControllerWillDismiss:(QRDisplayViewController *)qrDisplayVC {
    
}

#pragma mark - view handling

- (void)presentQRDisplayViewControllerWithPoint:(CGPoint)point {
    NSString *jsonString = [BTWorkout jsonForWorkout:self.workout];
    NSString *jsonString2 = [BTWorkout jsonForTemplateWorkout:self.workout];
    QRDisplayViewController *qVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qd"];
    qVC.image1 = [MMQRCodeMakerUtil qrImageWithContent:jsonString logoImage:nil qrColor:nil qrWidth:440];
    qVC.image2 = [MMQRCodeMakerUtil qrImageWithContent:jsonString2 logoImage:nil qrColor:nil qrWidth:440];
    qVC.point = point;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:qVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    qVC.transitioningDelegate = self.animator;
    qVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:qVC animated:YES completion:nil];
}

#pragma mark - scrollView delegate

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
//              targetContentOffset:(inout CGPoint *)targetContentOffset {
//    bool neglegable = fabs(velocity.y) < 0.2;
//    float offset = fabs(scrollView.contentOffset.y);
//    bool offsetPositive = scrollView.contentOffset.y >= 0;
//    bool velocityPositive = velocity.y >= 0;
//    if (neglegable && offset < 60.0) { } //no dismiss
//    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
//    else { //dismiss
//        [self animateOut];
//        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            if (scrollView.contentOffset.y >= 0)
//                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
//            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
//        } completion:^(BOOL finished) {}];
//    }
//}

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
        [self.delegate WorkoutSettingsViewControllerWillDismiss:self];
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
