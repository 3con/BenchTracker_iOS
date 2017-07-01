//
//  BTWorkout+CoreDataProperties.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTWorkout+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTWorkout (CoreDataProperties)

+ (NSFetchRequest<BTWorkout *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nonatomic) int64_t duration;
@property (nullable, nonatomic, copy) NSString *summary;   //"1 biceps#2 legs#..."
@property (nullable, nonatomic, retain) NSData *supersets; //[ [1, 2, 3], [5, 6], ... ]
@property (nullable, nonatomic, retain) NSOrderedSet<BTExercise *> *exercises;

@end

@interface BTWorkout (CoreDataGeneratedAccessors)

- (void)insertObject:(BTExercise *)value inExercisesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromExercisesAtIndex:(NSUInteger)idx;
- (void)insertExercises:(NSArray<BTExercise *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeExercisesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInExercisesAtIndex:(NSUInteger)idx withObject:(BTExercise *)value;
- (void)replaceExercisesAtIndexes:(NSIndexSet *)indexes withExercises:(NSArray<BTExercise *> *)values;
- (void)addExercisesObject:(BTExercise *)value;
- (void)removeExercisesObject:(BTExercise *)value;
- (void)addExercises:(NSOrderedSet<BTExercise *> *)values;
- (void)removeExercises:(NSOrderedSet<BTExercise *> *)values;

@end

NS_ASSUME_NONNULL_END
