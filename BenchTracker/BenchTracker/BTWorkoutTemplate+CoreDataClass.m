//
//  BTWorkoutTemplate+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 8/7/17.
//
//

#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTExerciseTemplate+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkoutTemplateModel.h"
#import "BTTemplateListModel.h"
#import "AppDelegate.h"

@implementation BTWorkoutTemplate

+ (void)checkForExistingTemplateList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTWorkoutTemplate fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TemplateListManager error: %@",error);
    else if (object.count == 0) {
        NSLog(@"No Template List, loading default");
        NSString *JSONString = [[NSString alloc] initWithData:[[NSDataAsset alloc] initWithName:@"DefaultTemplateList"].data
                                                     encoding:NSUTF8StringEncoding];
        BTTemplateListModel *model = [[BTTemplateListModel alloc] initWithString:JSONString error:&error];
        if (error) NSLog(@"templateList JSON model error:%@",error);
        else [self loadTemplateListModel:model];
    }
}

+ (BTTemplateListModel *)templateListModel {
    BTTemplateListModel *model = [[BTTemplateListModel alloc] init];
    model.userWorkouts = (NSMutableArray <BTWorkoutTemplateModel> *)[NSMutableArray array];
    model.defaultWorkouts = (NSMutableArray <BTWorkoutTemplateModel> *)[NSMutableArray array];
    for (BTWorkoutTemplate *wT in [BTWorkoutTemplate allWorkoutTemplates]) {
        BTWorkoutTemplateModel *workout = [[BTWorkoutTemplateModel alloc] init];
        workout.name = wT.name;
        workout.uuid = wT.uuid;
        workout.supersets = [NSKeyedUnarchiver unarchiveObjectWithData:wT.supersets];
        workout.summary = wT.summary;
        workout.exercises = (NSMutableArray <BTExerciseTemplateModel *><BTExerciseTemplateModel> *)[[NSMutableArray alloc] init];
        for (BTExerciseTemplate *eT in wT.exercises) {
            BTExerciseTemplateModel *exercise = [[BTExerciseTemplateModel alloc] init];
            exercise.name = eT.name;
            exercise.iteration = eT.iteration;
            exercise.category = eT.category;
            exercise.style = eT.style;
            [workout.exercises addObject:exercise];
        }
        if ([wT.source isEqualToString:TEMPLATE_SOURCE_USER]) [model.userWorkouts addObject:workout];
        else                                                  [model.defaultWorkouts addObject:workout];
    }
    return model;
}

+ (void)resetTemplateList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTWorkoutTemplate *template in [BTWorkoutTemplate allWorkoutTemplates])
        [context deleteObject:template];
    [context save:nil];
}

+ (void)loadTemplateListModel:(BTTemplateListModel *)model {
    [self loadWorkoutTemplateArray:model.userWorkouts source:TEMPLATE_SOURCE_USER];
    [self loadWorkoutTemplateArray:model.defaultWorkouts source:TEMPLATE_SOURCE_DEFAULT];
}

+ (BOOL)templateExistsForWorkout:(BTWorkout *)workout {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTWorkoutTemplate fetchRequest];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid == \"%@\"",workout.uuid]];
    return [context executeFetchRequest:request error:nil].count > 0;
}

+ (void)saveWorkoutToTemplateList:(BTWorkout *)workout {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    BTWorkoutTemplate *tW = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkoutTemplate" inManagedObjectContext:context];
    tW.source = TEMPLATE_SOURCE_USER;
    tW.name = workout.name;
    tW.uuid = workout.uuid;
    tW.supersets = workout.supersets;
    tW.summary = workout.summary;
    tW.exercises = [NSOrderedSet orderedSet];
    for (BTExercise *exercise in workout.exercises) {
        BTExerciseTemplate *eT = [NSEntityDescription insertNewObjectForEntityForName:@"BTExerciseTemplate" inManagedObjectContext:context];
        eT.name = exercise.name;
        eT.iteration = exercise.iteration;
        eT.category = exercise.category;
        eT.style = exercise.style;
        [tW addExercisesObject:eT];
    }
    [context save:nil];
}

+ (void)removeWorkoutFromTemplateList:(BTWorkout *)workout {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTWorkoutTemplate fetchRequest];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"uuid == \"%@\"",workout.uuid]];
    BTWorkoutTemplate *template = [context executeFetchRequest:request error:nil].firstObject;
    if (template) [context deleteObject:template];
    [context save:nil];
}

+ (BTWorkout *)workoutForWorkoutTemplate:(BTWorkoutTemplate *)workoutTemplate {
    BTWorkout *workout = [BTWorkout workout];
    workout.name = workoutTemplate.name;
    workout.summary = workoutTemplate.summary;
    workout.supersets = workoutTemplate.supersets;
    for (BTExerciseTemplate *eT in workoutTemplate.exercises) {
        BTExercise *exercise = [BTExerciseTemplate exerciseForExerciseTemplate:eT];
        exercise.workout = workout;
        [workout addExercisesObject:exercise];
    }
    return workout;
}

#pragma mark - private helper methods

+ (NSArray <BTWorkoutTemplate *> *)allWorkoutTemplates {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTWorkoutTemplate fetchRequest];
    request.fetchLimit = 0;
    request.fetchBatchSize = 0;
    return [context executeFetchRequest:request error:nil];
}

+ (void)loadWorkoutTemplateArray:(NSArray<BTWorkoutTemplateModel *><BTWorkoutTemplateModel> *) templates source:(NSString *)source {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTWorkoutTemplateModel *wT in templates) {
        BTWorkoutTemplate *workout = [NSEntityDescription insertNewObjectForEntityForName:@"BTWorkoutTemplate"
                                                                    inManagedObjectContext:context];
        workout.source = source;
        workout.name = wT.name;
        workout.uuid = wT.uuid;
        workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:wT.supersets];
        workout.summary = wT.summary;
        workout.exercises = [NSOrderedSet orderedSet];
        for (BTExerciseTemplate *eT in wT.exercises) {
            BTExerciseTemplate *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExerciseTemplate"
                                                                         inManagedObjectContext:context];
            exercise.name = eT.name;
            exercise.iteration = eT.iteration;
            exercise.category = eT.category;
            exercise.style = eT.style;
            [workout addExercisesObject:exercise];
        }
    }
    [context save:nil];
}

@end
