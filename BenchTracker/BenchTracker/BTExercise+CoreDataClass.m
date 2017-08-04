//
//  BTExercise+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExercise+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "BT1RMCalculator.h"

@implementation BTExercise

- (NSInteger)numberOfSets {
    return [[NSKeyedUnarchiver unarchiveObjectWithData:self.sets] count];
}

- (CGFloat)volume {
    if ([self.style isEqualToString:STYLE_REPSWEIGHT]) {
        CGFloat volume = 0;
        for (NSString *set in [NSKeyedUnarchiver unarchiveObjectWithData:self.sets]) {
            NSArray <NSString *> *split = [set componentsSeparatedByString:@" "];
            volume += split[0].floatValue*split[1].floatValue;
        }
        return volume;
    }
    return 0;
}

- (void)calculateOneRM {
    self.oneRM = 0;
    for (NSString *set in [NSKeyedUnarchiver unarchiveObjectWithData:self.sets]) {
        NSArray <NSString *> *split = [set componentsSeparatedByString:@" "];
        if ([self.style isEqualToString:STYLE_REPSWEIGHT])
            self.oneRM = MAX(self.oneRM, [BT1RMCalculator equivilentForReps:split[0].intValue weight:split[1].floatValue]);
        else if ([self.style isEqualToString:STYLE_REPS])
            self.oneRM = MAX(self.oneRM, split[0].intValue);
        else if ([self.style isEqualToString:STYLE_TIME])
            self.oneRM = MAX(self.oneRM, split[1].intValue);
        else if ([self.style isEqualToString:STYLE_TIMEWEIGHT])
            self.oneRM = MAX(self.oneRM, split[2].floatValue);
    }
}

@end
