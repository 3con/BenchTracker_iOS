//
//  BTExercise+CoreDataProperties.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExercise+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTExercise (CoreDataProperties)

+ (NSFetchRequest<BTExercise *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *sets;
@property (nullable, nonatomic, copy) NSString *style;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *iteration;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, retain) BTWorkout *workout;

@end

NS_ASSUME_NONNULL_END
