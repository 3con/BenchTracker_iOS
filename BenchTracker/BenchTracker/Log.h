//
//  Log.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Log : NSObject

+ (void)sendIdentity;

+ (void)event:(NSString *)event properties:(NSDictionary *)properties;

@end
