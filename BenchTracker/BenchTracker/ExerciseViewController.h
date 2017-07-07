//
//  ExerciseViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ExerciseViewController;
@class BTExercise;
@class BTSettings;

@protocol ExerciseViewControllerDelegate <NSObject>
@required
- (void) exerciseViewController:(ExerciseViewController *)exerciseVC willDismissWithEditedExercises:(NSArray <BTExercise *> *)exercises
                                                                                   deletedExercises:(NSArray <BTExercise *> *)deleted;
@end

@interface ExerciseViewController : UIViewController <UIScrollViewDelegate>

@property id<ExerciseViewControllerDelegate> delegate;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) NSArray <BTExercise *> *exercises;

@end
