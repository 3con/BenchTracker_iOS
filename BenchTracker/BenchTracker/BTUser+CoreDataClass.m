//
//  BTUser+CoreDataClass.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataClass.h"
#import "AppDelegate.h"

@implementation BTUser

- (void)setImage:(UIImage *)image {
    self.imageData = UIImagePNGRepresentation(image);
}

- (UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

+ (BTUser *)sharedInstance {
    static BTUser *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self fetchUser];
    });
    return sharedInstance;
}

#pragma mark - private methods

+ (BTUser *)fetchUser {
    NSFetchRequest *request = [BTUser fetchRequest];
    request.fetchLimit = 1;
    NSError *error;
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSArray *object = [context executeFetchRequest:request error:&error];
    if (error || object.count == 0) {
        NSLog(@"BTUser coreData error or creation: %@",error);
        BTUser *user = [NSEntityDescription insertNewObjectForEntityForName:@"BTUser" inManagedObjectContext:context];
        user.dateCreated = [NSDate date];
        [context save:nil];
        return user;
    }
    return object[0];
}


@end
