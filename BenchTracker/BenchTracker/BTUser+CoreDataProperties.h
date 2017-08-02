//
//  BTUser+CoreDataProperties.h
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "BTUser+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTUser (CoreDataProperties)

+ (NSFetchRequest<BTUser *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate* dateCreated;

@end

NS_ASSUME_NONNULL_END
