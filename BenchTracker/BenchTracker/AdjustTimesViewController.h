//
//  AdjustTimesViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/29/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AdjustTimesViewController;
@class BTWorkout;

@protocol AdjustTimesViewControllerDelegate <NSObject>
- (void)adjustTimesViewControllerWillDismiss:(AdjustTimesViewController *)adjustTimesVC;
@end

@interface AdjustTimesViewController : UIViewController <UIScrollViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic) id<AdjustTimesViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTWorkout *workout;

@property (nonatomic) CGPoint point;

@end
