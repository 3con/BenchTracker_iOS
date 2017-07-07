//
//  QRDisplayViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRDisplayViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic) CGPoint point;

@property (nonatomic) UIImage *image1;
@property (nonatomic) UIImage *image2;

@end
