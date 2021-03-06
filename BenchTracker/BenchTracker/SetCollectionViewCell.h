//
//  SetCollectionViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTCollectionViewCell.h"

@interface SetCollectionViewCell : BTCollectionViewCell

@property (nonatomic) UIColor *color;

@property (nonatomic) BOOL display1RM;

- (void)loadSetWithString:(NSString *)set weightSuffix:(NSString *)suffix;

- (void)performDeleteAnimationWithDuration: (float)duration;

@end
