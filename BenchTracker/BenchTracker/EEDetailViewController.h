//
//  EEDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"
#import "BTExerciseType+CoreDataClass.h"

@class EEDetailViewController;

@protocol EEDetailViewControllerDelegate <NSObject>
- (void)editExerciseDetailViewControllerWillDismiss:(EEDetailViewController *)eedVC;
@end

@interface EEDetailViewController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic) id<EEDetailViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@property (nonatomic) BTExerciseType *type;

@end
