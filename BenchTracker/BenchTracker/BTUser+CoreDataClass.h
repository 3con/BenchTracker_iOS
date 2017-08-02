//
//  BTUser+CoreDataClass.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BTWorkout;

NS_ASSUME_NONNULL_BEGIN

@interface BTUser : NSManagedObject

+ (BTUser *) sharedInstance;

@end

NS_ASSUME_NONNULL_END

#import "BTUser+CoreDataProperties.h"
