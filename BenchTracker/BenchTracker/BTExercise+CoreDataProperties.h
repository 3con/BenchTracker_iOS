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

@property (nullable, nonatomic, retain) NSData *sets; //repsSets: "10 50" reps: "10" timeWeight: "s 10 50" time: "s 10" custom: "~ xxxxxxxx"
@property (nonatomic) int64_t oneRM;
@property (nullable, nonatomic, copy) NSString *style;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *iteration;
@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, retain) BTWorkout *workout;

@end

NS_ASSUME_NONNULL_END
