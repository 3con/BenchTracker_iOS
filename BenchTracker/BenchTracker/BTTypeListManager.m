//
//  BTTypeListManager.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTTypeListManager.h"
#import "AppDelegate.h"
#import <AWSS3/AWSS3.h>
#import "BenchTrackerKeys.h"
#import "TypeListModel.h"

@interface BTTypeListManager ()

@property (nonatomic, strong) AWSS3TransferManager *manager;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation BTTypeListManager

+ (id)sharedInstance {
    static BTTypeListManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    });
    return sharedInstance;
}

#pragma mark - client -> server

- (void)uploadTypeList {
    //get all types
    //put back into typeListModel
    //send file
    [self.delegate typeListManagerDidEditList:self]; //update version number, send new user
}

#pragma mark - server -> client

- (void)checkForExistingTypeList {
    NSFetchRequest *request = [BTExerciseType fetchRequest];
    request.fetchLimit = 1;
    NSError *error = nil;
    NSArray *object = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"TypeListManager error: %@",error);
    else if (object.count == 0) {
        //Get default list
        NSLog(@"No Type List, fetching default");
        [self downloadListWithName:DEFAULT_LIST_NAME completionBlock:^(TypeListModel *model) {
            [self loadTypeListModelToCoreData:model];
        }];
    }
    else NSLog(@"Type List found");
}

- (void)fetchTypeList {
    //replace default with correct name
    /*
    [self downloadListWithName:DEFAULT_LIST_NAME completionBlock:^(TypeListModel *model) {
        [self loadTypeListModelToCoreData:model];
    }];
     */
}

#pragma mark - private methods

- (void)downloadListWithName: (NSString *)name completionBlock:(void (^)(TypeListModel * model))completed {
    //IMAGE DOWNLOAD
    self.manager = [AWSS3TransferManager defaultS3TransferManager];
    NSString *downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    NSURL *downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = AWS_BUCKET_NAME;
    downloadRequest.key = name;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    [[self.manager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error){
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"typeListManager get error: %@", task.error);
                        break;
                }
            }
            else NSLog(@"Error: %@", task.error);
        }
        if (task.result) {
            NSError *error;
            NSString *JSONString = [NSString stringWithContentsOfURL:downloadingFileURL encoding:NSUTF8StringEncoding error:&error];
            if(error) NSLog(@"typeList JSON model error:%@",error);
            TypeListModel *model = [[TypeListModel alloc] initWithString:JSONString error:&error];
            if(error) NSLog(@"typeList JSON model error:%@",error);
            completed(model);
        }
        return nil;
    }];
}

- (void)loadTypeListModelToCoreData: (TypeListModel *)model {
    for (ExerciseTypeModel *eT in model.list) {
        BTExerciseType *type = [NSEntityDescription insertNewObjectForEntityForName:@"BTExerciseType" inManagedObjectContext:self.context];
        type.name = eT.name;
        type.iterations = [NSKeyedArchiver archivedDataWithRootObject:eT.iterations];
        type.category = eT.category;
        type.style = eT.style;
    }
    BTSettings *settings = [NSEntityDescription insertNewObjectForEntityForName:@"BTSettings" inManagedObjectContext:self.context];
    for (int i = 0; i < model.colors.allKeys.count; i++) {
        NSString *key = model.colors.allKeys[i];
        model.colors[key] = [self colorForHex:model.colors[key]];
    }
    settings.exerciseTypeColors = [NSKeyedArchiver archivedDataWithRootObject:model.colors];
    [self saveCoreData];
}

- (UIColor *)colorForHex:(NSString *)hex {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (NSString *)hexForColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(components[0] * 255),
            lroundf(components[1] * 255),
            lroundf(components[2] * 255)];
}

- (void)saveCoreData {
    NSError *error;
    [self.context save:&error];
    if(error) NSLog(@"typeListManager error: %@",error);
}

@end
