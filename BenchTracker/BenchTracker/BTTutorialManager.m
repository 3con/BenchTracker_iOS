//
//  BTTutorialManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTTutorialManager.h"

@interface BTTutorialManager()
@property (nonatomic) OnboardingViewController *onboardingVC;
@end

@implementation BTTutorialManager

+ (BOOL)needsOnboarding {
    //[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"OnboardFinished"]; //Always enables Onboarding
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"OnboardFinished"] != YES;
}

- (OnboardingViewController *)onboardingViewControllerforSize:(CGSize)size { //Welcome, Intuitive, Powerful, Analytical, Get Started
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Welcome to\nBench Tracker"
                                                                                              body:@"Your new favorite workout tracker"
                                                                                             image:[UIImage imageNamed:@"Onboard1"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"Simple"
                                                                                              body:@"Designed to be intuitive"
                                                                                             image:[UIImage imageNamed:@"Onboard2"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"Analytical"
                                                                                              body:@"Explore your workouts like never before"
                                                                                             image:[UIImage imageNamed:@"Onboard3"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *fourthPage = [OnboardingContentViewController contentWithTitle:@"Powerful"
                                                                                              body:@"Unlock your full workout potential"
                                                                                             image:[UIImage imageNamed:@"Onboard4"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *fifthPage = [OnboardingContentViewController contentWithTitle:@"You're all set!"
                                                                                              body:@"Happy tracking!"
                                                                                             image:[UIImage imageNamed:@"Onboard1"]
                                                                                        buttonText:@"Get Started"
        action:^{
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OnboardFinished"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            __weak OnboardingViewController *weakOnboardingVC = self.onboardingVC;
            [weakOnboardingVC dismissViewControllerAnimated:YES completion:^{
            }];
        }];
    self.onboardingVC = [OnboardingViewController onboardWithBackgroundImage:nil
                                                                    contents:@[firstPage, secondPage, thirdPage, fourthPage, fifthPage]];
    float height = MIN(900, size.height*.8);
    CGSize screenshotSize = CGSizeMake(height*(1242.0/2419), height);
    for (OnboardingContentViewController *viewController in self.onboardingVC.viewControllers) {
        viewController.view.backgroundColor = [UIColor whiteColor];
        viewController.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
        viewController.bodyLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        viewController.actionButton.titleLabel.font = [UIFont systemFontOfSize:21 weight:UIFontWeightSemibold];
        viewController.titleLabel.textColor = [UIColor BTTutorialColor];
        viewController.bodyLabel.textColor = [UIColor BTTutorialColor];
        [viewController.actionButton setTitleColor:[UIColor BTTutorialColor] forState:UIControlStateNormal];
        viewController.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        viewController.iconHeight = screenshotSize.height;
        viewController.iconWidth = screenshotSize.width;
        viewController.topPadding = size.height-screenshotSize.height;
        viewController.underIconPadding = -(screenshotSize.height+80);
        viewController.underTitlePadding = 10;
        viewController.bottomPadding = 20;
    }
    self.onboardingVC.shouldFadeTransitions = YES;
    self.onboardingVC.fadeSkipButtonOnLastPage = YES;
    self.onboardingVC.fadePageControlOnLastPage = YES;
    self.onboardingVC.pageControl.backgroundColor = [UIColor colorWithWhite:1 alpha:.9];
    self.onboardingVC.pageControl.pageIndicatorTintColor = [[UIColor BTTutorialColor] colorWithAlphaComponent:.6];
    self.onboardingVC.pageControl.currentPageIndicatorTintColor = [UIColor BTTutorialColor];
    self.onboardingVC.allowSkipping = YES;
    __weak OnboardingViewController *weakOnboardingVC = self.onboardingVC;
    self.onboardingVC.skipHandler = ^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"OnboardFinished"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [weakOnboardingVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    self.onboardingVC.skipButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [self.onboardingVC.skipButton setTitleColor:[UIColor BTTutorialColor] forState:UIControlStateNormal];
    return self.onboardingVC;
}

@end
