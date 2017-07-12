//
//  BT1RMCalculator.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/11/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BT1RMCalculator.h"

@implementation BT1RMCalculator

+ (int)equivilentForReps:(int)reps weight:(float)weight {
    return weight/(1.0278-(.0278*reps));
}

@end
