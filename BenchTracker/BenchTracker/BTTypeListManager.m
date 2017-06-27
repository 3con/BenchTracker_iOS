//
//  BTTypeListManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTTypeListManager.h"
#import "BTExerciseType+CoreDataClass.h"
#import "AppDelegate.h"

@interface BTTypeListManager ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation BTTypeListManager

+ (id)sharedInstance {
    static BTTypeListManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)checkForExistingTypeList {
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
    else if (object.count == 0) {
        //Get default list
        NSLog(@"No List, fetching default");
    }
}

@end
