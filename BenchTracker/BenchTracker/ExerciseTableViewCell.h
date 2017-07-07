//
//  ExerciseTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

#define SUPERSET_NONE  @"none"
#define SUPERSET_ABOVE @"above"
#define SUPERSET_BELOW @"below"
#define SUPERSET_BOTH  @"both"

@class BTExercise;

@interface ExerciseTableViewCell : SWTableViewCell <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) BTExercise *exercise;

@property (nonatomic) UIColor *color;

@property (nonatomic) NSString *supersetMode;

- (void)loadExercise:(BTExercise *)exercise;

@end
