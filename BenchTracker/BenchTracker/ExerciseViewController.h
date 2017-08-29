//
//  ExerciseViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExerciseView.h"
#import "IterationSelectionViewController.h"

@class ExerciseViewController;
@class BTExercise;
@class BTSettings;

@protocol ExerciseViewControllerDelegate <NSObject>
@required
- (void)exerciseViewController:(ExerciseViewController *)exerciseVC didRequestSaveWithEditedExercises:(NSArray <BTExercise *> *)exercises
                                                                                     deletedExercises:(NSArray <BTExercise *> *)deleted
                                                                                             animated:(BOOL)animated;
- (void)exerciseViewDidAddSet:(ExerciseView *)exerciseView withResultExercise:(BTExercise *)exercise;
@end

@interface ExerciseViewController : UIViewController <UIScrollViewDelegate, ExerciseViewDelegate, IterationSelectionViewControllerDelegate>

@property id<ExerciseViewControllerDelegate> delegate;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) NSArray <BTExercise *> *exercises;

@end
