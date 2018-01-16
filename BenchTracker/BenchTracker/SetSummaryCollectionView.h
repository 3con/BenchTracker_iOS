//
//  SetSummaryCollectionView.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetSummaryCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSMutableArray <NSString *> *sets;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *textColor;

@property (nonatomic) BOOL enableOverlayLabel;

@end
