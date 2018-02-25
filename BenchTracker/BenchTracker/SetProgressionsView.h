//
//  SetProgressionsView.h
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExerciseType;

@interface SetProgressionsView : UIView

- (void)loadWithExerciseType:(BTExerciseType *)exerciseType iteration:(NSString *)iteration;

- (void)strokeChart;

@end
