//
//  UIColor+BTColors.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BTColor)

//BASE COLORS

+ (UIColor *)BTPrimaryColor;

+ (UIColor *)BTSecondaryColor;

+ (UIColor *)BTTertiaryColor;

//TEXT COLORS

+ (UIColor *)BTTextPrimaryColor;

+ (UIColor *)BTButtonTextPrimaryColor;

+ (UIColor *)BTButtonTextSecondaryColor;

//TV COLORS

+ (UIColor *)BTTableViewBackgroundColor;

+ (UIColor *)BTTableViewSeparatorColor;

//BUTTON COLORS

+ (UIColor *)BTButtonPrimaryColor;

+ (UIColor *)BTButtonSecondaryColor;

+ (UIColor *)BTRedColor;

//B+W COLORS

+ (UIColor *)BTBlackColor;

+ (UIColor *)BTGrayColor;

+ (UIColor *)BTLightGrayColor;

//VIBRANT COLORS

+ (NSArray <UIColor *> *)BTVibrantColors;

//STATUS BAR

+ (UIStatusBarStyle)statusBarStyle;

+ (UIKeyboardAppearance)keyboardAppearance;

@end
