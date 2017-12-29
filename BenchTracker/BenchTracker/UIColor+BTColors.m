//
//  UIColor+BTColors.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UIColor+BTColors.h"

@implementation UIColor (BTColor)

//colorScheme:
//0 = default
//1 = dark mode

+ (void)changeColorSchemeTo:(int)colorScheme {
    [[NSUserDefaults standardUserDefaults] setObject:@(colorScheme) forKey:@"colorScheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"colorSchemeChange" object:self];
}

+ (int)colorScheme {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"colorScheme"].intValue;
}

//BASE COLORS

+ (UIColor *)BTPrimaryColor {             //rgb(20,43,132)    //indigo 800 (r-20, g-10)
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:74/255.0 green:101/255.0 blue:139/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:36/255.0 green:51/255.0 blue:72/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTSecondaryColor {           //rgb(22,58,171)    //indigo 600 (r-25, g-15)
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:85/255.0 green:112/255.0 blue:151/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:40/255.0 green:62/255.0 blue:84/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTTertiaryColor {            //rgb(55,80,200)    //indigo 500 (r-30, g-20)
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:92/255.0 green:123/255.0 blue:167/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:50/255.0 green:75/255.0 blue:100/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTNavBarLineColor {
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        case 1: return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0];
        default: return nil;
    }
}

//TEXT COLORS

+ (UIColor *)BTTextPrimaryColor {         //rgb(255,255,255)   //white
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTButtonTextPrimaryColor {   //rgb(255,255,255)   //white
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTButtonTextSecondaryColor { //rgb(255,255,255)   //white
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        default: return nil;
    }
}

//TABLE VIEW COLORS

+ (UIColor *)BTTableViewBackgroundColor { //rgb(255,255,255)   //white
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:26/255.0 green:39/255.0 blue:55/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTGroupTableViewBackgroundColor { //rgb(235,235,241)
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:26/255.0 green:39/255.0 blue:55/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTTableViewSeparatorColor {  //rgb(188, 187, 193) //light gray - default
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:188/255.0 green:187/255.0 blue:193/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:0/255.0 green:4/255.0 blue:8/255.0 alpha:1];
        default: return nil;
    }
}

//BUTTON COLORS

+ (UIColor *)BTButtonPrimaryColor {       //rgb(251,192,45)   //yellow 700
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:251/255.0 green:192/255.0 blue:45/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:231/255.0 green:176/255.0 blue:38/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTButtonSecondaryColor {     //rgb(3,155,229)    //light blue 600
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:3/255.0 green:155/255.0 blue:229/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:3/255.0 green:141/255.0 blue:207/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTRedColor {                 //rgb(229,57,53)    //red 600
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:229/255.0 green:57/255.0 blue:53/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:194/255.0 green:49/255.0 blue:46/255.0 alpha:1];
        default: return nil;
    }
}

//B+W COLORS

+ (UIColor *)BTBlackColor {               //rgb(40,40,40)     //gray 900
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTGrayColor {                //rgb(97,97,97)     //gray 700
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:136/255.0 green:154/255.0 blue:168/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTLightGrayColor {           //rgb(158,158,158)  //gray 500
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1];
        case 1: return [UIColor colorWithRed:136/255.0 green:154/255.0 blue:168/255.0 alpha:1];
        default: return nil;
    }
}

+ (UIColor *)BTModalViewBackgroundColor { //Note: Only alpha compenent is used for exerciseVC, addExerciseVC
    switch ([self colorScheme]) {
        case 0: return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.6];
        case 1: return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.4];
        default: return nil;
    }
}

//VIBRANT COLORS

+ (NSArray <UIColor *> *)BTVibrantColors {
    //@"00BCD4", @"2ECC71", @"2196F3", @"673AB7", @"EC407A", @"F44336", @"FF9800"
    return @[[UIColor colorWithRed:0/255.0 green:188/255.0 blue:212/255.0 alpha:1],   //Turquoise
             [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1],  //Green
             [UIColor colorWithRed:33/255.0 green:150/255.0 blue:243/255.0 alpha:1],  //Light blue
             [UIColor colorWithRed:103/255.0 green:58/255.0 blue:183/255.0 alpha:1],  //Purple
             [UIColor colorWithRed:236/255.0 green:64/255.0 blue:122/255.0 alpha:1],  //Pink
             [UIColor colorWithRed:244/255.0 green:67/255.0 blue:54/255.0 alpha:1],   //Red
             [UIColor colorWithRed:255/255.0 green:152/255.0 blue:0/255.0 alpha:1]];  //Orange
}

//STATUS BAR

+ (UIStatusBarStyle)statusBarStyle {
    switch ([self colorScheme]) {
        case 0: return UIStatusBarStyleLightContent;
        case 1: return UIStatusBarStyleLightContent;
        default: return UIStatusBarStyleDefault;
    }
}

+ (UIKeyboardAppearance)keyboardAppearance {
    switch ([self colorScheme]) {
        case 0: return UIKeyboardAppearanceLight;
        case 1: return UIKeyboardAppearanceDark;
        default: return UIKeyboardAppearanceDefault;
    }
}

@end
