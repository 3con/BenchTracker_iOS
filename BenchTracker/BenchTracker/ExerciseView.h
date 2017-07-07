//
//  ExerciseView.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExercise;

@interface ExerciseView : UIView <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) BOOL isDeleted;

@property (nonatomic) UIColor *color;

- (void)loadExercise:(BTExercise *)exercise;

- (BTExercise *)getExercise;

@end
