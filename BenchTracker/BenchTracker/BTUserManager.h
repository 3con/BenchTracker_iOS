//
//  BTUserManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTUser+CoreDataClass.h"

@interface BTUserManager : NSObject

+ (id)sharedInstance;

- (BTUser *)user;

- (void)updateUserFromAWS;

//CoreData user does not exist

- (BOOL)userExistsWithUsername: (NSString *)username continueWithBlock:(void (^)(BOOL exists))completed;

- (void)createUserWithUsername: (NSString *)username completionBlock:(void (^)())completed;

- (void)copyUserFromAWS: (NSString *)username completionBlock:(void (^)())completed;

@end
