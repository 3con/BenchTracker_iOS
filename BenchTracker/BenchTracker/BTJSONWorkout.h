//
//  BTJSONWorkout.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTJSONExercise;

@interface BTJSONWorkout : NSObject

@property (nonatomic)                   NSString* uuid;
@property (nonatomic)                   NSString* name;
@property (nonatomic)                   NSString* date;
@property (nonatomic)                   NSNumber* duration;
@property (nonatomic) NSMutableArray<NSString *>* supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTJSONExercise *>* exercises;

@end

@interface BTJSONExercise : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;
@property (nonatomic) NSMutableArray *sets; //repsSets: "10 50" reps: "10" timeWeight: "s 10 50" time: "s 10" custom: "~ xxxxxxxx"

@end

