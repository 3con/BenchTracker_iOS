//
//  TypeListModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ExerciseTypeModel @end

@interface ExerciseTypeModel : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <NSString *> *iterations;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *style;

@end

@interface TypeListModel : JSONModel

@property (nonatomic, strong) NSArray <ExerciseTypeModel> *list;

@end
