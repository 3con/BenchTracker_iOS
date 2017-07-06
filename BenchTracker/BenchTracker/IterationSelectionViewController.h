//
//  IterationSelectionViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExerciseType;
@class IterationSelectionViewController;

@protocol IterationSelectionViewControllerDelegate <NSObject>
- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration;
- (void)iterationSelectionVCDidDismiss:(IterationSelectionViewController *)iterationVC;
@end

@interface IterationSelectionViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic) id<IterationSelectionViewControllerDelegate> delegate;

@property (nonatomic) BTExerciseType *exerciseType;
@property (nonatomic) CGPoint originPoint;
@property (nonatomic) UIColor *color;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
