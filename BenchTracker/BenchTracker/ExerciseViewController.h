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

@protocol ExerciseViewControllerDelegate <NSObject>
@required
- (void) exerciseViewController:(ExerciseViewController *)exerciseVC willDismissWithEditedExercises:(NSArray <BTExercise *> *)exercises
                                                                                   deletedExercises:(NSArray <BTExercise *> *)deleted;
@end

@interface ExerciseViewController : UIViewController

@property id<ExerciseViewControllerDelegate> delegate;

@property (nonatomic) NSArray <BTExercise *> *exercises;

@end
