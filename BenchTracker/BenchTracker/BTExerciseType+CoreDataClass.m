//
//  BTExerciseType+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExerciseType+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "AppDelegate.h"
#import "BTTypeListModel.h"
#import "BTSettings+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "BT1RMCalculator.h"

@implementation BTExerciseType

#pragma mark - client

+ (void)checkForExistingTypeList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.fetchLimit = 1;
    NSError *error;
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
    else if (object.count == 0) {
        NSLog(@"No Type List, loading default");
        NSString *JSONString = [[NSString alloc] initWithData:[[NSDataAsset alloc] initWithName:@"DefaultExerciseTypeList"].data
                                                     encoding:NSUTF8StringEncoding];
        BTTypeListModel *model = [[BTTypeListModel alloc] initWithString:JSONString error:&error];
        if (error) NSLog(@"typeList JSON model error:%@",error);
        else [self loadTypeListModel:model];
    }
}

+ (BTTypeListModel *)typeListModel {
    BTTypeListModel *model = [[BTTypeListModel alloc] init];
    model.list = (NSMutableArray <BTExerciseTypeModel> *)[NSMutableArray array];
    for (BTExerciseType *eT in [BTExerciseType allExerciseTypes]) {
        BTExerciseTypeModel *type = [[BTExerciseTypeModel alloc] init];
        type.name = eT.name;
        type.iterations = [NSKeyedUnarchiver unarchiveObjectWithData:eT.iterations];
        type.category = eT.category;
        type.style = eT.style;
        [model.list addObject:type];
    }
    BTSettings *settings = [BTSettings sharedInstance];
    model.colors = [NSMutableDictionary dictionary];
    NSDictionary *exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:settings.exerciseTypeColors];
    for (NSString *key in exerciseTypeColors.allKeys)
        model.colors[key] = [BTExerciseType hexForColor:exerciseTypeColors[key]];
    return model;
}

+ (void)resetTypeList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTExerciseType *type in [BTExerciseType allExerciseTypes])
        [context deleteObject:type];
    [context save:nil];
}

+ (void)loadTypeListModel:(BTTypeListModel *)model {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    for (BTExerciseTypeModel *eT in model.list) {
        BTExerciseType *type = [NSEntityDescription insertNewObjectForEntityForName:@"BTExerciseType" inManagedObjectContext:context];
        type.name = eT.name;
        type.iterations = [NSKeyedArchiver archivedDataWithRootObject:eT.iterations];
        type.category = eT.category;
        type.style = eT.style;
    }
    BTSettings *settings = [BTSettings sharedInstance];
    for (int i = 0; i < model.colors.allKeys.count; i++) {
        NSString *key = model.colors.allKeys[i];
        model.colors[key] = [BTExerciseType colorForHex:model.colors[key]];
    }
    settings.exerciseTypeColors = [NSKeyedArchiver archivedDataWithRootObject:model.colors];
    [context save:nil];
}

+ (BTExerciseType *)typeForExercise:(BTExercise *)exercise {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == \"%@\"",exercise.name]];
    request.fetchLimit = 1;
    NSArray *arr = [context executeFetchRequest:request error:nil];
    return (arr && arr.count > 0) ? arr.firstObject : nil;
}

- (NSArray<BTExercise *> *)allInstancesOfIteration:(NSString *)iteration {
    return [self recentInstances:INT_MAX withIteration:iteration];
}

- (NSArray<NSArray<NSNumber *> *> *)recentSetProgressionsForIteration:(NSString *)iteration {
    NSMutableArray <NSMutableArray <NSNumber *> *> *arr = @[].mutableCopy;
    NSArray *exercises = [self recentInstances:10 withIteration:iteration];
    for (BTExercise *exercise in exercises) {
        NSMutableArray<NSNumber *> *setProgression = @[].mutableCopy;
        for (NSString *set in [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets]) {
            NSArray *sSet = [set componentsSeparatedByString:@" "];
            [setProgression addObject:[NSNumber numberWithInt:(sSet.count == 1) ?
                [sSet[0] intValue] : [BT1RMCalculator equivilentForReps:[sSet[0] intValue] weight:[sSet[1] floatValue]]]];
        }
        if (setProgression.count > 1) [arr addObject:setProgression];
    }
    return arr;
}

- (NSDictionary<NSString *, NSNumber *> *)recentSmartNameSplitsForIteration:(NSString *)iteration {
    NSMutableDictionary<NSString *, NSNumber *> *dict = @{}.mutableCopy;
    NSArray *exercises = [self recentInstances:20 withIteration:iteration];
    for (BTExercise *exercise in exercises) {
        if (exercise.workout.smartName) {
            if (!dict[exercise.workout.smartNickname]) dict[exercise.workout.smartNickname] = [NSNumber numberWithInt:1];
            else dict[exercise.workout.smartNickname] = [NSNumber numberWithInt:dict[exercise.workout.smartNickname].intValue+1];
        }
    }
    return dict;
}

#pragma mark - private methods

- (NSArray <BTExercise *> *)recentInstances:(int)num withIteration:(NSString *)iteration {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExercise fetchRequest];
    NSPredicate *p1 = (iteration != nil && iteration.length > 0) ? [NSPredicate predicateWithFormat:@"iteration = %@", iteration] : nil;
    NSPredicate *p2 = [NSPredicate predicateWithFormat:@"name = %@", self.name];
    request.predicate = (p1) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]] : p2;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"workout.date" ascending:NO]];
    request.fetchLimit = num;
    NSError *error;
    return [context executeFetchRequest:request error:&error];
}

+ (NSArray <BTExerciseType *> *)allExerciseTypes {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.fetchLimit = 0;
    request.fetchBatchSize = 0;
    return [context executeFetchRequest:request error:nil];
}

+ (UIColor *)colorForHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"%02lX%02lX%02lX",
            lroundf(components[0] * 255),
            lroundf(components[1] * 255),
            lroundf(components[2] * 255)];
}

@end
