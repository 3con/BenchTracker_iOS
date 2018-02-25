//
//  BTViewMoreView.h
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTExerciseType;

@interface BTViewMoreView : UIView

@property (nonatomic) UIColor *color;

@property (nonatomic) BTExerciseType *exerciseType;
@property (nonatomic) NSString *iteration;

@property (nonatomic) BOOL expanded;
@property (nonatomic) float preferredHeight;

@end
