//
//  ExerciseView.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SetCollectionView.h"

@class BTExercise;
@class BTSettings;
@class ExerciseView;

@protocol ExerciseViewDelegate <NSObject>
- (void)exerciseViewDidAddSet:(ExerciseView *)exerciseView;
- (void)exerciseViewRequestedEditIteration:(ExerciseView *)exerciseView withPoint:(CGPoint)point;
- (void)exerciseViewRequestedShowExerciseDetails:(ExerciseView *)exerciseView;
- (void)exerciseViewRequestedShowTable:(ExerciseView *)exerciseView;
@end

@interface ExerciseView : UIView <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, SetCollectionViewDataSource>

@property (nonatomic) id<ExerciseViewDelegate> delegate;

@property (nonatomic) BOOL isDeleted;

@property (nonatomic) BTSettings *settings;
@property (nonatomic) UIColor *color;

- (void)loadExercise:(BTExercise *)exercise;

- (void)setIteration:(NSString *)iteration;

- (void)reloadData;

- (BTExercise *)getExercise;

@end
