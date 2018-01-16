//
//  BTExerciseTemplate+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTExerciseTemplate+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTExerciseTemplate (CoreDataProperties)

+ (NSFetchRequest<BTExerciseTemplate *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *category;
@property (nullable, nonatomic, copy) NSString *iteration;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *style;
@property (nullable, nonatomic, retain) BTWorkoutTemplate *workout;

@end

NS_ASSUME_NONNULL_END
