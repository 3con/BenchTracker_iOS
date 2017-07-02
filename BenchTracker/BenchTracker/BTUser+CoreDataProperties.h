//
//  BTUser+CoreDataProperties.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTUser (CoreDataProperties)

+ (NSFetchRequest<BTUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *username;
@property (nullable, nonatomic, copy) NSDate* dateCreated;
@property (nullable, nonatomic, copy) NSDate* lastUpdate;
@property (nonatomic) int32_t typeListVersion;
@property (nullable, nonatomic, retain) NSData *recentEdits;
@property (nullable, nonatomic, retain) NSOrderedSet<BTWorkout *> *workouts;

@end

@interface BTUser (CoreDataGeneratedAccessors)

- (void)insertObject:(BTWorkout *)value inWorkoutsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromWorkoutsAtIndex:(NSUInteger)idx;
- (void)insertWorkouts:(NSArray<BTWorkout *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeWorkoutsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInWorkoutsAtIndex:(NSUInteger)idx withObject:(BTWorkout *)value;
- (void)replaceWorkoutsAtIndexes:(NSIndexSet *)indexes withWorkouts:(NSArray<BTWorkout *> *)values;
- (void)addWorkoutsObject:(BTWorkout *)value;
- (void)removeWorkoutsObject:(BTWorkout *)value;
- (void)addWorkouts:(NSOrderedSet<BTWorkout *> *)values;
- (void)removeWorkouts:(NSOrderedSet<BTWorkout *> *)values;

@end

NS_ASSUME_NONNULL_END
