//
//  AppDelegate.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/5/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (BOOL)loadNewStoreWithURL:(NSURL *)url;

- (NSURL *)defualtStoreURL;

- (void)saveContext;

- (NSURL *)applicationDocumentsDirectory;

- (void)resetCoreData;

@end

