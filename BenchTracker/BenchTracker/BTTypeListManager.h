//
//  BTTypeListManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BTTypeListManager : NSObject

+ (id)sharedInstance;

//client -> server

- (void)uploadTypeList;

//server -> client

- (void)checkForExistingTypeList;

- (void)fetchTypeList;

@end
