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

@property (weak, nonatomic) IBOutlet UIButton *adjustDatesButton;
@property (weak, nonatomic) IBOutlet UIButton *qrButton;
@property (weak, nonatomic) IBOutlet UIButton *printButton;
@property (weak, nonatomic) IBOutlet UIButton *templateButton;
@property (weak, nonatomic) IBOutlet UIButton *darkModeButton;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@end

@implementation WorkoutSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    [self updateInterface];
    self.contentView.layer.cornerRadius = 25;
    self.contentView.clipsToBounds = YES;
    self.doneButton.layer.cornerRadius = 12;
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.doneButton.alpha = 0.0;
    [self updateTemplateButton];
    [Log event:@"WorkoutSettingsVC: Presentation" properties:nil];
}

- (void)updateInterface {
    self.contentView.backgroundColor = [UIColor BTPrimaryColor];
    self.backgroundView.backgroundColor = [UIColor BTModalViewBackgroundColor];
    for (UIButton *button in @[self.adjustDatesButton, self.qrButton, self.printButton,
                               self.templateButton, self.darkModeButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.backgroundColor = [UIColor BTSecondaryColor];
        [button setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
        [button setImage:[button.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                forState:UIControlStateNormal];
        button.tintColor = [UIColor BTTextPrimaryColor];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    self.detailLabel.textColor = [UIColor BTTextPrimaryColor];
    self.doneButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.doneButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
    [self.darkModeButton setTitle:([UIColor colorScheme] == 0) ? @"Enable dark mode" : @"Disable dark mode"
                         forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateInfo];
}

- (void)updateInfo {
    NSString *name = (self.workout.name.length < 20) ? self.workout.name :
        [NSString stringWithFormat:@"%@...",[self.workout.name substringToIndex:17]];
    NSDateFormatter *yFormatter = [[NSDateFormatter alloc] init];
    [yFormatter setDateFormat:@"M/d/yy"];
    NSDateFormatter *dFormatter = [[NSDateFormatter alloc] init];
    [dFormatter setDateFormat:@"h:mma"];
    NSString *smartText = @"";
    if (@available(iOS 11, *))
        if (self.settings.showSmartNames && self.workout.smartName)
            smartText = [NSString stringWithFormat:@"Smart name: %@\n", self.workout.smartNickname];
    NSString *str = [NSString stringWithFormat:
                     @"%@ (%@)\n%@Exercises: %lld, Sets: %lld\nVolume: %lld %@\nStart: %@, Duration: %lld min",
                     name, [yFormatter stringFromDate:self.workout.date], smartText,
                     self.workout.numExercises, self.workout.numSets, self.workout.volume,
                     self.settings.weightSuffix, [[dFormatter stringFromDate:self.workout.date] lowercaseString],
                     self.workout.duration/60];
    NSMutableAttributedString *aStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 16;
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

- (IBAction)adjustDatesButtonPressed:(UIButton *)sender {
    [Log event:@"WorkoutSettingsVC: Adjust dates" properties:nil];
    [self presentAdjustTimesViewControllerWithPoint:[self.view convertPoint:sender.center fromView:self.contentView]];
    self.doneButton.hidden = YES;
}

- (IBAction)qrButtonPressed:(UIButton *)sender {
    [Log event:@"WorkoutSettingsVC: QR" properties:nil];
    [self presentQRDisplayViewControllerWithPoint:[self.view convertPoint:sender.center fromView:self.contentView]];
    self.doneButton.hidden = YES;
}

- (IBAction)printButtonPressed:(UIButton *)sender {
    [Log event:@"WorkoutSettingsVC: Print" properties:nil];
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

- (IBAction)darkModeButtonPressed:(UIButton *)sender {
    [Log event:@"WorkoutSettingsVC: Dark mode" properties:nil];
    int colorScheme = [UIColor colorScheme];
    [UIColor changeColorSchemeTo:(colorScheme+1)%2];
    [self updateInterface];
}

- (IBAction)templateButtonPressed:(UIButton *)sender {
    [Log event:@"WorkoutSettingsVC: Template" properties:nil];
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
            [self.templateButton setImage:[[UIImage imageNamed:@"TemplateAdd"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                 forState:UIControlStateNormal];
        }
        else {
            [self.templateButton setTitle:@"Remove from templates" forState:UIControlStateNormal];
            [self.templateButton setImage:[[UIImage imageNamed:@"TemplateDelete"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                                 forState:UIControlStateNormal];
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
    [Log event:@"WorkoutSettingsVC: Secret duration" properties:nil];
    UIAlertController * alertController =
        [UIAlertController alertControllerWithTitle: @"Manual Duration"
                                            message: @"Please enter your workout duration in minutes. Be aware that if you continue adding sets workout duration will still increment."
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"%lld mins", self.workout.duration/60];
        textField.textColor = [UIColor darkGrayColor];
        textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Done"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
        UITextField *durationField = alertController.textFields.firstObject;
        if (durationField.text && durationField.text.length > 0)
            self.workout.duration = durationField.text.integerValue * 60;
        [self.context save:nil];
        [self updateInfo];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - adjustTimesVC delegate

- (void)adjustTimesViewControllerWillDismiss:(AdjustTimesViewController *)adjustTimesVC {
    [self updateInfo];
    self.doneButton.hidden = NO;
}

#pragma mark - qrVC delegate

- (void)QRDisplayViewControllerWillDismiss:(QRDisplayViewController *)qrDisplayVC {
    self.doneButton.hidden = NO;
}

#pragma mark - printInteractionVC delegate

- (void)printInteractionControllerWillDismissPrinterOptions:(UIPrintInteractionController *)printController {
    
}

#pragma mark - view handling

- (void)presentAdjustTimesViewControllerWithPoint:(CGPoint)point {
    AdjustTimesViewController *atVC = [self.storyboard instantiateViewControllerWithIdentifier:@"at"];
    atVC.delegate = self;
    atVC.point = point;
    atVC.context = self.context;
    atVC.workout = self.workout;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:atVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    atVC.transitioningDelegate = self.animator;
    atVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:atVC animated:YES completion:nil];
}

- (void)presentQRDisplayViewControllerWithPoint:(CGPoint)point {
    NSString *jsonString = [BTWorkout jsonForWorkout:self.workout];
    NSString *jsonString2 = [BTWorkout jsonForTemplateWorkout:self.workout];
    QRDisplayViewController *qVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qd"];
    qVC.image1 = [MMQRCodeMakerUtil qrImageWithContent:jsonString logoImage:nil qrColor:nil qrWidth:440];
    qVC.image2 = [MMQRCodeMakerUtil qrImageWithContent:jsonString2 logoImage:nil qrColor:nil qrWidth:440];
    qVC.point = point;
    qVC.delegate = self;
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
