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
#import "AppDelegate.h"

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

+ (NSInteger)powerliftingTotalWeight {
    NSInteger benchMax = [BTExercise oneRMForExerciseName:@"Barbell Bench Press"];
    NSInteger deadliftMax = [BTExercise oneRMForExerciseName:@"Deadlift"];
    NSInteger squatMax = [BTExercise oneRMForExerciseName:@"Squats"];
    return (benchMax > 0 && deadliftMax > 0 && squatMax > 0) ? benchMax + deadliftMax + squatMax : 0;
}

- (BTExercise *)lastInstance {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTExercise"];
    NSMutableArray *pArr = @[[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == \"%@\"", self.name]],
                             [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"category == \"%@\"", self.category]],
                             [NSPredicate predicateWithFormat:@"workout != %@", self.workout]].mutableCopy;
    if (self.iteration) [pArr addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"iteration == \"%@\"", self.iteration]]];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:pArr];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"workout.date" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    NSArray <BTExercise *> *results = [context executeFetchRequest:fetchRequest error:nil];
    return (results && results.count > 0) ? results.firstObject : nil;
}

+ (NSInteger)oneRMForExerciseName:(NSString *)name {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTExercise"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'",name]];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"oneRM" ascending:NO]];
    fetchRequest.fetchLimit = 1;
    NSArray <BTExercise *> *results = [context executeFetchRequest:fetchRequest error:nil];
    return (results && results.count > 0) ? results.firstObject.oneRM : 0;
}

@end
