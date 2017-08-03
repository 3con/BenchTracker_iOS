//
//  BTTemplateWorkoutModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTTemplateExerciseModel;

@interface BTTemplateWorkoutModel : NSObject

@property (nonatomic)                   NSString* name;
@property (nonatomic) NSMutableArray<NSString *>* supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTTemplateExerciseModel *>* exercises;

@end

@interface BTTemplateExerciseModel : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;

@end
