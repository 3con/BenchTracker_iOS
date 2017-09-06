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

@property (nonatomic) NSString *name;
@property (nonatomic) NSArray <NSString *> *iterations;
@property (nonatomic) NSString *category;
@property (nonatomic) NSString *style;

@end

@interface BTTypeListModel : JSONModel

@property (nonatomic) NSMutableArray <BTExerciseTypeModel> *list;
@property (nonatomic) NSMutableDictionary *colors;

@end
