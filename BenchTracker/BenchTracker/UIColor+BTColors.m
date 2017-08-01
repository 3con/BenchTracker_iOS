//
//  UIColor+BTColors.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UIColor+BTColors.h"

@implementation UIColor (BTColor)

+ (UIColor *)BTPrimaryColor {           //rgb(16,41,131)    //indigo 600 (darkened)
    return [UIColor colorWithRed:21/255.0 green:54/255.0 blue:171/255.0 alpha:1];
}

+ (UIColor *)BTSecondaryColor {         //rgb(21,54,171)    //---
    return [UIColor colorWithRed:25/255.0 green:64/255.0 blue:201/255.0 alpha:1];
}

+ (UIColor *)BTTertiaryColor {          //rgb(22,66,222)    //---
    return [UIColor colorWithRed:34/255.0 green:78/255.0 blue:245/255.0 alpha:1];
}

+ (UIColor *)BTButtonPrimaryColor {     //rgb(251,192,45)   //yellow 700
    return [UIColor colorWithRed:251/255.0 green:192/255.0 blue:45/255.0 alpha:1];
}

+ (UIColor *)BTButtonSecondaryColor {   //rgb(3,155,229)    //light blue 600
    return [UIColor colorWithRed:3/255.0 green:155/255.0 blue:229/255.0 alpha:1];
}

+ (UIColor *)BTBlackColor {             //rgb(33,33,33)     //gray 900
    return [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
}

+ (UIColor *)BTGrayColor {              //rgb(97,97,97)     //gray 700
    return [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1];
}

+ (UIColor *)BTRedColor {               //rgb(229,57,53)    //red 600
    return [UIColor colorWithRed:229/255.0 green:57/255.0 blue:53/255.0 alpha:1];
}

@end
