//
//  ExerciseViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExercise;

@interface ExerciseViewController : UIViewController

@property (nonatomic) NSArray <BTExercise *> *exercises;

@end
