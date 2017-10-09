//
//  SetCollectionView.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTSettings;
@class SetCollectionView;

@protocol SetCollectionViewDataSource <NSObject>
- (NSString *)setToAddForSetCollectionView:(SetCollectionView *)collectionView;
@end

@interface SetCollectionView : UICollectionView <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) id<SetCollectionViewDataSource> setDataSource;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) NSMutableArray <NSString *> *sets;

@property (nonatomic) BOOL display1RM;

@end
