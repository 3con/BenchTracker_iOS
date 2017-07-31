//
//  BTSettings+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 7/14/17.
//
//

#import "BTSettings+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@class BTWorkout;

@interface BTSettings (CoreDataProperties)

+ (NSFetchRequest<BTSettings *> *)fetchRequest;

@property (nullable, nonatomic, retain) BTWorkout *activeWorkout;
@property (nullable, nonatomic, retain) NSData *hiddenExerciseTypeSections;
@property (nullable, nonatomic, retain) NSData *exerciseTypeColors;

@property (nonatomic) BOOL startWeekOnMonday;
@property (nonatomic) BOOL disableSleep;
@property (nonatomic) BOOL weightInLbs;

@end

NS_ASSUME_NONNULL_END
