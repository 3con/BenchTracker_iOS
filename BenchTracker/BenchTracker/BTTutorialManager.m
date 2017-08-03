//
//  BTTutorialManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTTutorialManager.h"

@implementation BTTutorialManager

+ (BOOL)needsOnboarding {
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"OnboardProgress"]; //Always enables Onboarding
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"OnboardProgress"] < 5;
}

+ (OnboardingViewController *)onboardingVC { //Welcome, Intuitive, Powerful, Analytical, Get Started
    OnboardingViewController *onboardingVC;
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"Welcome to Bench Tracker"
                                                                                              body:@"Your new favorite workout tracker."
                                                                                             image:[UIImage imageNamed:@"Onboard1"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"Simple"
                                                                                              body:@"Designed to be intuitive."
                                                                                             image:[UIImage imageNamed:@"Onboard2"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"Analytical"
                                                                                              body:@"Explore your workouts like never before."
                                                                                             image:[UIImage imageNamed:@"Onboard3"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *fourthPage = [OnboardingContentViewController contentWithTitle:@"Powerful"
                                                                                              body:@"Unlock your full workout potential."
                                                                                             image:[UIImage imageNamed:@"Onboard4"]
                                                                                        buttonText:nil
                                                                                            action:nil];
    OnboardingContentViewController *fifthPage = [OnboardingContentViewController contentWithTitle:@""
                                                                                              body:@""
                                                                                             image:[UIImage imageNamed:@"Onboard5"]
                                                                                        buttonText:@"Get Started"
        action:^{
            [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"OnboardProgress"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            __weak OnboardingViewController *weakOnboardingVC = onboardingVC;
            [weakOnboardingVC dismissViewControllerAnimated:YES completion:^{
            }];
        }];
    onboardingVC = [OnboardingViewController onboardWithBackgroundImage:nil
                                                contents:@[firstPage, secondPage, thirdPage, fourthPage, fifthPage]];
    for (OnboardingContentViewController *viewController in onboardingVC.viewControllers) {
        viewController.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightMedium];
        viewController.bodyLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        viewController.actionButton.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        viewController.titleLabel.textColor = [UIColor BTSecondaryColor];
        viewController.bodyLabel.textColor = [UIColor BTSecondaryColor];
        [viewController.actionButton setTitleColor:[UIColor BTTertiaryColor] forState:UIControlStateNormal];
        viewController.iconHeight = 120;
        viewController.iconWidth = 120;
        viewController.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        viewController.view.backgroundColor = [UIColor whiteColor];
        viewController.topPadding = 300; //self.view.frame.size.height*.4
        viewController.underIconPadding = -300;
        viewController.underTitlePadding = 10;
        viewController.bottomPadding = 25;
    }
    onboardingVC.shouldFadeTransitions = YES;
    onboardingVC.shouldBlurBackground = NO;
    onboardingVC.shouldMaskBackground = NO;
    onboardingVC.allowSkipping = YES;
    onboardingVC.pageControl.pageIndicatorTintColor = [UIColor BTTertiaryColor];
    onboardingVC.pageControl.currentPageIndicatorTintColor = [UIColor BTSecondaryColor];
    onboardingVC.skipButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    [onboardingVC.skipButton setTitleColor:[UIColor BTTertiaryColor] forState:UIControlStateNormal];
    __weak OnboardingViewController *weakOnboardingVC = onboardingVC;
    onboardingVC.skipHandler = ^{
        [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"OnboardProgress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [weakOnboardingVC dismissViewControllerAnimated:YES completion:^{
            
        }];
    };
    return onboardingVC;
}

@end
