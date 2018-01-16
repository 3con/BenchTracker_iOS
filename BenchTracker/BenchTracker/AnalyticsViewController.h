//
//  AnalyticsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnalyticsCollectionViewCell.h"

@class AnalyticsViewController;

@protocol AnalyticsViewControllerDelegate <NSObject>

@end

@interface AnalyticsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) id<AnalyticsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@end
