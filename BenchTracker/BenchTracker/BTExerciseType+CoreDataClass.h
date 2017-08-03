//
//  BTExerciseType+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@class BTTypeListModel;

@interface BTExerciseType : NSManagedObject

+ (void)checkForExistingTypeList;

+ (BTTypeListModel *)typeListModel;

+ (void)loadTypeListModel:(BTTypeListModel *)model;

@end

NS_ASSUME_NONNULL_END

#import "BTExerciseType+CoreDataProperties.h"
