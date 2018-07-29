//
//  BTExerciseTemplate+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTExerciseTemplate+CoreDataClass.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "AppDelegate.h"

@implementation BTExerciseTemplate

+ (BTExercise *)exerciseForExerciseTemplate:(BTExerciseTemplate *)exerciseTemplate {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:context];
    exercise.name = exerciseTemplate.name;
    exercise.iteration = exerciseTemplate.iteration;
    exercise.category = exerciseTemplate.category;
    exercise.style = exerciseTemplate.style;
    exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:@[].mutableCopy];
    exercise.oneRM = 0;
    exercise.volume = 0;
    return exercise;
}

@end
