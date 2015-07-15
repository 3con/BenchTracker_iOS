//
//  step.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Step : NSObject

@property NSString *name;

@property int sets;

@property NSMutableArray *reps;
@property NSMutableArray *weight;

- (id)initWithName: (NSString *)n;

- (void) addSetWithReps: (int)r Weight: (int) w;

- (void) removeSetAtIndex: (int) index;

@end
