//
//  BTWorkoutModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class BTExerciseModel;

@protocol BTWorkoutModel;
@protocol BTExerciseModel;

@interface BTWorkoutModel : JSONModel

@property (nonatomic) NSString *uuid;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *date;
@property (nonatomic) BOOL dateModified;
@property (nonatomic) NSNumber *duration;
@property (nonatomic) NSMutableArray<NSString *> *supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTExerciseModel *> <BTExerciseModel> *exercises;

@end

@interface BTExerciseModel : JSONModel

@property (nonatomic) NSString *name;
@property (nonatomic) NSString <Optional> *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;
@property (nonatomic) NSMutableArray *sets; //repsSets: "10 50" reps: "10" timeWeight: "s 10 50" time: "s 10" custom: "~ xxxxxxxx"

@end
