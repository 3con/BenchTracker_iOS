//
//  AppDelegate.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/5/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "AppDelegate.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "BenchTrackerKeys.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"
#import "BTUser+CoreDataClass.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTAchievement+CoreDataClass.h"
#import "Appirater.h"
#import "BTDataTransferManager.h"
#import "MainViewController.h"
#import "WorkoutViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Amplitude.h"

#define ROOTVIEW [[[UIApplication sharedApplication] keyWindow] rootViewController]

@interface AppDelegate ()

@end

@implementation AppDelegate
            

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    //COGNITO HANDLING
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          initWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:AWS_POOL_ID];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    //TYPE LIST HANDLING
    [BTExerciseType checkForExistingTypeList];
    //SMART NAMES
    [BTWorkout calculateAllSmartNames];
    //EXERCISE VOLUMES
    [BTExercise calculateAllVolumes];
    //TEMPLATE LIST HANDLING
    [BTWorkoutTemplate checkForExistingTemplateList];
    //ACHIEVEMENT LIST HANDLING
    [BTAchievement checkAchievementList];
    [BTUser checkForTotalsPurge];
    [BTUser updateStreaks];
    //APPIRATER
    [Appirater setAppId:@"1266077653"];
    [Appirater setDaysUntilPrompt:999];
    [Appirater setUsesUntilPrompt:999];
    [Appirater setSignificantEventsUntilPrompt:2];
    [Appirater setTimeBeforeReminding:3];
    [Appirater setCustomAlertTitle:@"Rate Weightlifting App"];
    [Appirater setCustomAlertMessage:@"If you are enjoying using Weightlifting App, would you mind taking a moment to rate it? It truly means the world to us. Your support is what keeps us going!"];
    [Appirater setCustomAlertRateButtonTitle:@"Rate Weightlifting App"];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    //CRASHLYTICS
    [Fabric with:@[[Crashlytics class]]];
    //AMPLITUDE
    [Amplitude.instance initializeApiKey:AMPLITUDE_KEY];
    [Log sendIdentity];
    [Log event:@"App Open" properties:nil];
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem
                                                            completionHandler:(void (^)(BOOL))completionHandler {
    [Log event:@"AppDelegate: Performed shortcut" properties:@{@"Shortcut": shortcutItem.type}];
    if ([shortcutItem.type isEqualToString:@"com.chappyasel.benchtracker.newworkout"]) {
        if (ROOTVIEW.class == WorkoutViewController.class) return;
        if (ROOTVIEW.class != MainViewController.class) {
            MainViewController *mVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"m"];
            [ROOTVIEW presentViewController:mVC animated:NO completion:^{
                [mVC performSelector:@selector(presentWorkoutViewControllerWithWorkout:) withObject:nil afterDelay:.2];
            }];
        }
        else {
            [ROOTVIEW performSelector:@selector(presentWorkoutViewControllerWithWorkout:) withObject:nil afterDelay:.2];
        }
        
    }
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    UIAlertController *alertController;
    if ([self loadNewStoreWithURL:url]) { //Successfully loaded file
        [Log event:@"AppDelegate: Import data" properties:@{@"Success": @"True"}];
        alertController = [UIAlertController
            alertControllerWithTitle:@"Import Successful!"
                             message:@"Your settings, workouts, and custom exercises have all been successfully imported. Happy tracking!"
                      preferredStyle:UIAlertControllerStyleAlert];
    } else { //Failed to load file
        [Log event:@"AppDelegate: Import data" properties:@{@"Success": @"False"}];
        alertController = [UIAlertController
            alertControllerWithTitle:@"Import Failed"
                             message:@"Unfortunately, we could not import your data. Please make sure the version of Weightlifting App on this app is the same as the one you used to export and that no data was lost between the transfer. We apoligize for the inconvenience."
                      preferredStyle:UIAlertControllerStyleAlert];
    }
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    alertWindow.rootViewController = [[UIViewController alloc] init];
    alertWindow.windowLevel = UIWindowLevelAlert + 1;
    [alertWindow makeKeyAndVisible];
    [alertWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [Log event:@"App Terminated" properties:nil];
    [self saveContext];
}

#pragma mark - public methods

- (BOOL)loadNewStoreWithURL:(NSURL *)url {
    if (url && url.isFileURL)
        return [BTDataTransferManager loadJSONDataWithURL:url];
    return NO;
}
            
- (NSURL *)defualtStoreURL {
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BenchTracker.sqlite"];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

// The directory the application uses to store the Core Data store file. This code uses a directory named "CDdesigns.Homework" in the application's documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) return _managedObjectModel;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BTDataModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) return _persistentStoreCoordinator;
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [self defualtStoreURL];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES, NSInferMappingModelAutomaticallyOption : @YES };
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) return _managedObjectContext;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) return nil;
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)resetCoreData {
    [self.persistentStoreCoordinator destroyPersistentStoreAtURL:[self defualtStoreURL] withType:NSSQLiteStoreType options:nil error:nil];
    self.managedObjectContext = nil;
    self.persistentStoreCoordinator = nil;
}

@end
