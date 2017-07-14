//
//  SetCollectionViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetCollectionViewCell : UICollectionViewCell

@property (nonatomic) UIColor *color;

- (void)loadSetWithString:(NSString *)set weightSuffix:(NSString *)suffix;

- (void)performDeleteAnimationWithDuration: (float)duration;

@end
