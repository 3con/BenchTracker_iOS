//
//  BTWorkoutTemplate+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTWorkoutTemplate+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTWorkoutTemplate (CoreDataProperties)

+ (NSFetchRequest<BTWorkoutTemplate *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *source;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *supersets;
@property (nullable, nonatomic, copy) NSString *uuid;
@property (nullable, nonatomic, copy) NSString *summary;
@property (nullable, nonatomic, retain) NSOrderedSet<BTExerciseTemplate *> *exercises;

@end

@interface BTWorkoutTemplate (CoreDataGeneratedAccessors)

- (void)insertObject:(BTExerciseTemplate *)value inExercisesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromExercisesAtIndex:(NSUInteger)idx;
- (void)insertExercises:(NSArray<BTExerciseTemplate *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeExercisesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInExercisesAtIndex:(NSUInteger)idx withObject:(BTExerciseTemplate *)value;
- (void)replaceExercisesAtIndexes:(NSIndexSet *)indexes withExercises:(NSArray<BTExerciseTemplate *> *)values;
- (void)addExercisesObject:(BTExerciseTemplate *)value;
- (void)removeExercisesObject:(BTExerciseTemplate *)value;
- (void)addExercises:(NSOrderedSet<BTExerciseTemplate *> *)values;
- (void)removeExercises:(NSOrderedSet<BTExerciseTemplate *> *)values;

@end

NS_ASSUME_NONNULL_END
