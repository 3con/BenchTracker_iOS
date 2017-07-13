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
    if(reps<18) return (100*weight)/(48.8+53.8*powf(M_E, -.075*reps)); //Wathan Equation
    return weight*(1+reps/30); //Epley Formula
    //According to LeSuer et al. 1997 (based off bench, squat, and deadlift; men and women; early 20s)
}

@end
