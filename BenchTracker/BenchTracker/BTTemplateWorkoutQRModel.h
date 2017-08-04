//
//  BTTemplateQRWorkoutModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTTemplateExerciseQRModel;

@interface BTTemplateWorkoutQRModel : NSObject

@property (nonatomic)                   NSString* name;
@property (nonatomic) NSMutableArray<NSString *>* supersets; //[ "1 2 3", "5 6", ... ]
@property (nonatomic) NSMutableArray<BTTemplateExerciseQRModel *>* exercises;

@end

@interface BTTemplateExerciseQRModel : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *iteration;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;

@end
