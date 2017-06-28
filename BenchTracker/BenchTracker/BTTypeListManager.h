//
//  BTTypeListManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTTypeListManager;

@protocol BTTypeListManagerDelegate <NSObject>
@required
- (void) typeListManagerDidEditList:(BTTypeListManager *)typeListManager;
@end

@interface BTTypeListManager : NSObject

@property id<BTTypeListManagerDelegate> delegate;

+ (id)sharedInstance;

//client -> server

- (void)uploadTypeList;

//server -> client

- (void)checkForExistingTypeList;

- (void)fetchTypeList;

@end
