//
//  UIViewController+BTPresentation.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "UIViewController+BTPresentation.h"
#import "ZFModalTransitionAnimator.h"

@interface UIViewController ()
@property (nonatomic) ZFModalTransitionAnimator *animator;
@end

@implementation UIViewController (BTPresentation)

- (void)presentViewController:(UIViewController *)viewController withStyle:(BTPresentationStyle)style {
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:viewController];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewScale = 1.0;
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    switch (style) {
        case BTPresentationStyleFromBottom:
            self.animator.behindViewAlpha = 0.8;
            self.animator.transitionDuration = 0.5;
            self.animator.direction = ZFModalTransitonDirectionBottom;
            break;
        case BTPresentationStyleFromRight:
            self.animator.dragable = YES;
            self.animator.behindViewAlpha = 0.6;
            self.animator.transitionDuration = 0.35;
            self.animator.direction = ZFModalTransitonDirectionRight;
            break;
        case BTPresentationStyleFromLeft:
            self.animator.dragable = YES;
            self.animator.behindViewAlpha = 0.6;
            self.animator.transitionDuration = 0.35;
            self.animator.direction = ZFModalTransitonDirectionLeft;
            break;
        case BTPresentationStyleNone:
            self.animator.behindViewAlpha = 1.0;
            self.animator.transitionDuration = 0.0;
            self.animator.direction = ZFModalTransitonDirectionBottom;
            viewController.modalPresentationStyle = UIModalPresentationCustom;
            break;
    }
    viewController.transitioningDelegate = self.animator;
    [self presentViewController:viewController animated:YES completion:nil];
}

@end
