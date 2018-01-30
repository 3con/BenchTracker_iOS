//
//  BTUserModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BTUserModel : JSONModel

@property (nonatomic) NSDate *dateCreated;
@property (nonatomic) NSString <Optional> *name;
@property (nonatomic) NSString <Optional> *imageData;
@property (nonatomic) NSNumber <Optional> *weight;

@property (nonatomic) NSNumber *achievementListVersion;
@property (nonatomic) NSNumber *xp;

@property (nonatomic) NSNumber *totalSets;
@property (nonatomic) NSNumber *totalExercises;
@property (nonatomic) NSNumber *totalDuration;
@property (nonatomic) NSNumber *totalVolume;
@property (nonatomic) NSNumber *totalWorkouts;
@property (nonatomic) NSNumber *currentStreak;
@property (nonatomic) NSNumber *longestStreak;

@end
