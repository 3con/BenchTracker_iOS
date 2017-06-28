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

//client only

- (BTUser *)user;

//client -> server

- (void)createUserWithUsername: (NSString *)username completionBlock:(void (^)())completed;

//server -> client

- (void)updateUserFromAWS;

- (void)copyUserFromAWS: (NSString *)username completionBlock:(void (^)())completed;

//server only

- (void)userExistsWithUsername: (NSString *)username continueWithBlock:(void (^)(BOOL exists))completed;

@end
