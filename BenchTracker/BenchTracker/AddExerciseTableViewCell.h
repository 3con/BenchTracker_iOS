//
//  AddExerciseTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExerciseType;

@interface AddExerciseTableViewCell : UITableViewCell

@property (nonatomic) BOOL cellSelected;

@property (nonatomic) BTExerciseType *exerciseType;
@property (nonatomic) NSString *iteration;
@property (nonatomic) UIColor *color;

- (void)loadExerciseType: (BTExerciseType *)exerciseType;

- (void)loadIteration:(NSString *)iteration;

@end
