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

- (void)createUserWithUsername: (NSString *)username;

- (void)pushUserToAWS;

- (void)updateUserFromAWS;

@end
