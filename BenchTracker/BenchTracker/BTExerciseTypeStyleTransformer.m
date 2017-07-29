//
//  BTExerciseTypeStyleTransformer.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExerciseTypeStyleTransformer.h"

@implementation BTExerciseTypeStyleTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (NSString *)transformedValue:(NSString *)value {
    return (value == nil) ? nil : @{@"reps" : @"Reps only",
                                    @"repsWeight" : @"Reps and weight",
                                    @"time" : @"Duration only",
                                    @"timeWeight" : @"Duration and weight",
                                    @"custom" : @"Custom text",}[value];
}

@end
