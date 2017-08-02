//
//  BTExerciseType+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTExerciseType+CoreDataClass.h"
#import "AppDelegate.h"
#import "TypeListModel.h"
#import "BTSettings+CoreDataClass.h"

@implementation BTExerciseType

#pragma mark - client

+ (void)checkForExistingTypeList {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
    else if (object.count == 0) {
        NSLog(@"No Type List, loading default");
        //GET DEFAULT LIST
    }
}

#pragma mark - private methods

+ (void)loadTypeListModelToCoreData: (TypeListModel *)model withContext:(NSManagedObjectContext *)context {
    for (ExerciseTypeModel *eT in model.list) {
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

+ (UIColor *)colorForHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)hexForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(components[0] * 255),
            lroundf(components[1] * 255),
            lroundf(components[2] * 255)];
}

@end
