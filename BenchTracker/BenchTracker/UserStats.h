//
//  UserStats.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/15/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTUser;
@class BTSettings;

@interface UserStats : NSObject

+ (UserStats *)statsWithUser:(BTUser *)user settings:(BTSettings *)settings;

- (NSArray<NSString *> *)statForIndex:(int)index;

- (NSInteger)numStats;

@end
