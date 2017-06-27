//
//  BTExerciseType+CoreDataProperties.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExerciseType+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTExerciseType (CoreDataProperties)

+ (NSFetchRequest<BTExerciseType *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *style;
@property (nullable, nonatomic, retain) NSData *iterations;

@end

NS_ASSUME_NONNULL_END
