//
//  ExerciseModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ExerciseModel : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *iteration;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSNumber *oneRM;
@property (nonatomic, strong) NSArray <NSString *> *sets;

@end
