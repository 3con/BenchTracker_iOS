//
//  BTSettings+CoreDataClass.h
//  
//
//  Created by Chappy Asel on 7/1/17.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface BTSettings : NSManagedObject

+ (BTSettings *) sharedInstance;

- (void)reset;

- (NSString *)weightSuffix;

@end

NS_ASSUME_NONNULL_END

#import "BTSettings+CoreDataProperties.h"
