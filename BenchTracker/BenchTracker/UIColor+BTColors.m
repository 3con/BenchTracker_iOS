//
//  UIColor+BTColors.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "UIColor+BTColors.h"

@implementation UIColor (BTColor)

//BASE COLORS

+ (UIColor *)BTPrimaryColor {           //rgb(20,43,132)    //indigo 800 (r-20, g-10)
    return [UIColor colorWithRed:15/255.0 green:43/255.0 blue:132/255.0 alpha:1];
}

+ (UIColor *)BTSecondaryColor {         //rgb(22,58,171)    //indigo 600 (r-25, g-15)
    return [UIColor colorWithRed:22/255.0 green:58/255.0 blue:171/255.0 alpha:1];
}

+ (UIColor *)BTTertiaryColor {          //rgb(55,80,200)    //indigo 500 (r-30, g-20)
    return [UIColor colorWithRed:55/255.0 green:80/255.0 blue:200/255.0 alpha:1];
}

//BUTTON COLORS

+ (UIColor *)BTButtonPrimaryColor {     //rgb(251,192,45)   //yellow 700
    return [UIColor colorWithRed:251/255.0 green:192/255.0 blue:45/255.0 alpha:1];
}

+ (UIColor *)BTButtonSecondaryColor {   //rgb(3,155,229)    //light blue 600
    return [UIColor colorWithRed:3/255.0 green:155/255.0 blue:229/255.0 alpha:1];
}

+ (UIColor *)BTRedColor {               //rgb(229,57,53)    //red 600
    return [UIColor colorWithRed:229/255.0 green:57/255.0 blue:53/255.0 alpha:1];
}

//B+W COLORS

+ (UIColor *)BTBlackColor {             //rgb(40,40,40)     //gray 900
    return [UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:1];
}

+ (UIColor *)BTGrayColor {              //rgb(97,97,97)     //gray 700
    return [UIColor colorWithRed:97/255.0 green:97/255.0 blue:97/255.0 alpha:1];
}

+ (UIColor *)BTLightGrayColor {         //rgb(158,158,158)  //gray 500
    return [UIColor colorWithRed:158/255.0 green:158/255.0 blue:158/255.0 alpha:1];
}

//VIBRANT COLORS

+ (NSArray <UIColor *> *)BTVibrantColors {
    //@"00BCD4", @"2ECC71", @"2196F3", @"673AB7", @"EC407A", @"F44336", @"FF9800"
    return @[[UIColor colorWithRed:0/255.0 green:188/255.0 blue:212/255.0 alpha:1],  //Turquoise
             [UIColor colorWithRed:46/255.0 green:204/255.0 blue:113/255.0 alpha:1], //Green
             [UIColor colorWithRed:33/255.0 green:150/255.0 blue:243/255.0 alpha:1], //Light blue
             [UIColor colorWithRed:103/255.0 green:58/255.0 blue:183/255.0 alpha:1], //Purple
             [UIColor colorWithRed:236/255.0 green:64/255.0 blue:122/255.0 alpha:1], //Pink
             [UIColor colorWithRed:244/255.0 green:67/255.0 blue:54/255.0 alpha:1],  //Red
             [UIColor colorWithRed:255/255.0 green:152/255.0 blue:0/255.0 alpha:1]]; //Orange
}

@end
