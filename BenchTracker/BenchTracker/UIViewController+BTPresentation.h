//
//  UIViewController+BTPresentation.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum BTPresentationStyle : NSInteger {
    BTPresentationStyleFromBottom,
    BTPresentationStyleFromLeft,
    BTPresentationStyleFromRight,
    BTPresentationStyleNone
} BTPresentationStyle;

@interface UIViewController (BTPresentation)

- (void)presentViewController:(UIViewController *)viewController withStyle:(BTPresentationStyle)style;

@end
