//
//  BTTypeListModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol BTExerciseTypeModel @end

@interface BTExerciseTypeModel : JSONModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray <NSString *> *iterations;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *style;

@end

@interface BTTypeListModel : JSONModel

@property (nonatomic, strong) NSMutableArray <BTExerciseTypeModel> *list;
@property (nonatomic, strong) NSMutableDictionary *colors;

@end
