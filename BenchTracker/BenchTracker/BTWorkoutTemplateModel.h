//
//  BTWorkoutTemplateModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class BTExerciseTemplateModel;

@protocol BTWorkoutTemplateModel;
@protocol BTExerciseTemplateModel;

@interface BTWorkoutTemplateModel : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSString <Optional> *uuid;
@property (nonatomic) NSString *summary;
@property (nonatomic) NSMutableArray<NSString *> *supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTExerciseTemplateModel *> <BTExerciseTemplateModel> *exercises;

@end

@interface BTExerciseTemplateModel : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSString <Optional> *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;

@end
