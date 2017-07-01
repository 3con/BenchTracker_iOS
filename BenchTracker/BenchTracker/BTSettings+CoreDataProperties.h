//
//  BTSettings+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 7/1/17.
//
//

#import "BTSettings+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTSettings (CoreDataProperties)

+ (NSFetchRequest<BTSettings *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *exerciseTypeColors;

@end

NS_ASSUME_NONNULL_END
