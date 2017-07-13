//
//  ADPodiumView.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADPodiumView : UIView

@property (nonatomic) UIColor *color;

@property (nonatomic) NSArray <NSDate *> *dates;
@property (nonatomic) NSArray <NSString *> *values;
@property (nonatomic) NSArray <NSString *> *subValues;

@end
