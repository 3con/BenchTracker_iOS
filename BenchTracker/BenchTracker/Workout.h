//
//  Workout.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Workout : NSObject

@property NSString *title;
@property NSDate *date;

@property NSMutableArray *steps;

- (id)initWithTitle: (NSString *)t Date: (NSDate *)d;

- (void)addStepWithName: (NSString *)n;

@end
