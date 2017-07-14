//
//  ADEDExerciseTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExercise;

@interface ADEDExerciseTableViewCell : UITableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) UIColor *color;

- (void)loadExercise:(BTExercise *)exercise withWeightSuffix:(NSString *)suffix;

@end
