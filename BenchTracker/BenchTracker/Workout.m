//
//  Workout.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "Workout.h"
#import "Step.h"

@implementation Workout

- (id)init{
    return [self initWithTitle:nil Date:nil];
}

- (id)initWithTitle: (NSString *)t Date: (NSDate *)d {
    self.title = t;
    self.date = d;
    _steps = [[NSMutableArray alloc] init];
    return self;
    
}

// ((steps (name, sets) -> ((set ((rep, weight))))))

- (void)addStepWithName: (NSString *)n {
    [_steps addObject:[[Step alloc] initWithName:n]];
    NSLog(@"STEPS: %ld",self.steps.count);
}

- (void)addSetAtStep: (int) s WithReps: (int)r Weight: (int)w {
    [_steps[s] addSetWithReps:r Weight:w];
}

@end
