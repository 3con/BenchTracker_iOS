//
//  EEDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTExerciseType+CoreDataClass.h"

@class EEDetailViewController;

@protocol EEDetailViewControllerDelegate <NSObject>
- (void)editExerciseDetailViewController:(EEDetailViewController *)eedVC willDismissWithResultExerciseType:(BTExerciseType *)type;
- (void)editExerciseDetailViewController:(EEDetailViewController *)eedVC willDismissWithDeletedExerciseType:(BTExerciseType *)type;
@end

@interface EEDetailViewController : UIViewController

@property (nonatomic) id<EEDetailViewControllerDelegate> delegate;

@property (nonatomic) BTExerciseType *type;

@end
