//
//  BTJSONWorkoutTemplate.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTJSONExerciseTemplate;

@interface BTJSONWorkoutTemplate : NSObject

@property (nonatomic)                   NSString* name;
@property (nonatomic)                   NSString* summary;   //"1 biceps#2 legs#..."
@property (nonatomic) NSMutableArray<NSString *>* supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTJSONExerciseTemplate *>* exercises;

@end

@interface BTJSONExerciseTemplate : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;

@end
