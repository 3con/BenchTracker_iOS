//
//  BTTutorialManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnboardingViewController.h"

@interface BTTutorialManager : NSObject

+ (BOOL)needsOnboarding;

- (OnboardingViewController *)onboardingViewControllerforSize:(CGSize)size;

@end
