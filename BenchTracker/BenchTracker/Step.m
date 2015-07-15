//
//  step.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "Step.h"

@implementation Step

- (id)init{
    return [self initWithName:nil];
}

- (id)initWithName: (NSString *)n {
    self.name = n;
    _reps = [[NSMutableArray alloc] init];
    _weight = [[NSMutableArray alloc] init];
    return self;
}

- (void) addSetWithReps: (int)r Weight: (int) w {
    [_reps addObject:[NSNumber numberWithInt:r]];
    [_weight addObject:[NSNumber numberWithInt:w]];
    _sets ++;
}

- (void) removeSetAtIndex: (int) index {
    [_reps removeObjectAtIndex:index];
    [_weight removeObjectAtIndex:index];
    _sets --;
}

@end
