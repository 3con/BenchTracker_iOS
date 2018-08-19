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

@property (nullable, nonatomic, copy) NSDate *dateCreated;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, retain) NSData *imageData;

@property (nonatomic) int32_t weight;
@property (nonatomic) int32_t achievementListVersion;

@property (nonatomic) int32_t xp;

@property (nonatomic) int64_t totalDuration;
@property (nonatomic) int64_t totalVolume;
@property (nonatomic) int64_t totalWorkouts;
@property (nonatomic) int64_t totalSets;
@property (nonatomic) int64_t totalExercises;

@property (nonatomic) int64_t currentStreak;
@property (nonatomic) int64_t longestStreak;

@end

NS_ASSUME_NONNULL_END
