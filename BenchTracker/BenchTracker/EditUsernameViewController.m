//
//  EditUsernameViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/18/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EditUsernameViewController.h"
#import "BTUser+CoreDataClass.h"

@interface EditUsernameViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *containingView;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;

@end

@implementation EditUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.containingView.backgroundColor = [UIColor BTVibrantColors][1];
    self.textField.textColor = [UIColor BTGrayColor];
    self.textField.tintColor = [UIColor BTVibrantColors][1];
    self.textField.delegate = self;
    self.containingView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.errorLabel.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.textField.text = self.user.name;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self animateOut];
}

- (IBAction)changeButtonPressed:(UIButton *)sender {
    self.errorLabel.hidden = YES;
    if (self.textField.text.length < 3) {
        self.errorLabel.text = @"Must be at least 3 characters";
        self.errorLabel.hidden = NO;
        return;
    }
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@" " options:NSRegularExpressionCaseInsensitive error:&error];
    NSUInteger numMatches = [regex numberOfMatchesInString:self.textField.text options:0 range:NSMakeRange(0, self.textField.text.length)];
    if (numMatches > 2) {
        self.errorLabel.text = @"No more than 2 spaces";
        self.errorLabel.hidden = NO;
        return;
    }
    for (NSString *s in @[@"Fuck", @"Shit", @"Penis", @"Nigg", @"Faggot", @"Nazi", @"Bitch", @"Pussy"]) {
        if ([self.textField.text containsString:s]) {
            self.errorLabel.text = @"Cannot contain profanity";
            self.errorLabel.hidden = NO;
            return;
        }
    }
    NSMutableCharacterSet *characters = [NSCharacterSet alphanumericCharacterSet].mutableCopy;
    [characters addCharactersInString:@" .-_!?+"];
    NSCharacterSet *unwantedCharacters = [characters invertedSet];
    if ([self.textField.text rangeOfCharacterFromSet:unwantedCharacters].location != NSNotFound) {
        self.errorLabel.text = @"Please delete invalid characters";
        self.errorLabel.hidden = NO;
        return;
    }
    [self.activityIndicator startAnimating];
    [self.user userExistsWithUsername:self.textField.text continueWithBlock:^(BOOL exists) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (exists) {
                [self.activityIndicator stopAnimating];
                self.errorLabel.text = @"User already exists";
                self.errorLabel.hidden = NO;
            }
            else {
                [self.user changeUserToUsername:self.textField.text continueWithBlock:^(BOOL success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.activityIndicator stopAnimating];
                        if (!success) {
                            self.errorLabel.text = @"Unknown error. Try again later";
                            self.errorLabel.hidden = NO;
                        }
                        else {
                            self.errorLabel.text = @"Success!";
                            self.errorLabel.textColor = [UIColor whiteColor];
                            self.errorLabel.hidden = NO;
                            [self performSelector:@selector(animateOut) withObject:nil afterDelay:.5];
                            [self.delegate editUsernameViewControllerWillDismissWithUpdatedUsername:self];
                        }
                    });
                }];
            }
        });
    }];
}

#pragma mark - scrollView delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    bool neglegable = fabs(velocity.y) < 0.2;
    float offset = fabs(scrollView.contentOffset.y);
    bool offsetPositive = scrollView.contentOffset.y >= 0;
    bool velocityPositive = velocity.y >= 0;
    if (neglegable && offset < 60.0) { } //no dismiss
    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
    else { //dismiss
        [self animateOut];
        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (scrollView.contentOffset.y >= 0)
                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - textField delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if(range.length + range.location > textField.text.length) return NO;
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 20;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

#pragma mark - animation

- (void)animateIn {
    self.containingView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.containingView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    CGPoint endPoint = self.containingView.center;
    self.containingView.center = self.originPoint;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containingView.transform = CGAffineTransformIdentity;
        self.containingView.center = endPoint;
        self.containingView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.containingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
