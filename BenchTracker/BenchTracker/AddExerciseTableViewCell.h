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

@property BTExerciseType *exerciseType;
@property UIColor *color;

- (void)loadExerciseType: (BTExerciseType *)exerciseType;

@end
