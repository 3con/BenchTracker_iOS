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
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *imageData;
@property (nonatomic) NSNumber *weight;

@property (nonatomic) NSNumber *achievementListVersion;
@property (nonatomic) NSNumber *xp;

@property (nonatomic) NSNumber *totalDuration;
@property (nonatomic) NSNumber *totalVolume;
@property (nonatomic) NSNumber *totalWorkouts;
@property (nonatomic) NSNumber *currentStreak;
@property (nonatomic) NSNumber *longestStreak;

@end
