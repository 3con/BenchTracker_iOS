//
//  BTToastManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "BTToastManager.h"
#import "UIView+Toast.h"
#import "BTAchievement+CoreDataClass.h"
#import "MainViewController.h"

@implementation BTToastManager

+ (void)setUpToasts {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.horizontalPadding = 32;
    style.verticalPadding = 32;
    style.cornerRadius = 12;
    style.imageSize = CGSizeMake(32, 32);
    [CSToastManager setSharedStyle:style];
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setQueueEnabled:YES];
}

+ (void)presentToastForAchievement:(BTAchievement *)achievement {
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.backgroundColor = [UIColor BTVibrantColors][0];
    style.cornerRadius = 12;
    style.verticalPadding = 20;
    style.horizontalPadding = 20;
    style.titleFont = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
    style.messageFont = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    style.titleAlignment = NSTextAlignmentCenter;
    style.messageAlignment = NSTextAlignmentCenter;
    style.maxWidthPercentage = 90;
    style.imageSize = CGSizeMake(80, 80);
    style.fadeDuration = .25;
    NSString *str = [NSString stringWithFormat:@"ACHIEVEMENT UNLOCKED!\n+%d xp (Level %ld)",
                     achievement.xp, (long)[BTUser sharedInstance].level];
    UIViewController *viewController = [BTToastManager topMostController];
    [viewController.view makeToast:str
                          duration:3.0
                          position:CSToastPositionTop
                             title:achievement.name
                             image:achievement.image
                             style:style
                        completion:^(BOOL didTap) {
        if (didTap && [viewController isKindOfClass:[MainViewController class]])
            [(MainViewController *)viewController presentUserViewControllerWithForwardToAcheivements:YES];
    }];
    if ([viewController isKindOfClass:[MainViewController class]])
        [(MainViewController *)viewController updateBadgeView];
}

+ (void)presentToastForTemplate:(BOOL)isAddition {
    CSToastStyle *style = [CSToastManager sharedStyle];
    style.backgroundColor = (isAddition) ? [[UIColor BTButtonSecondaryColor] colorWithAlphaComponent:.8] :
                                           [[UIColor BTRedColor] colorWithAlphaComponent:.8];
    UIViewController *viewController = [BTToastManager topMostController];
    [viewController.view makeToast:nil
                          duration:0.5
                          position:CSToastPositionCenter
                             title:nil
                             image:[UIImage imageNamed:(isAddition) ? @"TemplateAdd" : @"TemplateDelete"]
                             style:nil
                        completion:nil];
}

+ (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) topController = topController.presentedViewController;
    return topController;
}

@end
