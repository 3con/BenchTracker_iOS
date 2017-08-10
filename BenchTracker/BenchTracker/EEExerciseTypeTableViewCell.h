//
//  EEExerciseTypeTableViewCell.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface EEExerciseTypeTableViewCell : MGSwipeTableCell

- (void)loadWithName:(NSString *)name;

@end
