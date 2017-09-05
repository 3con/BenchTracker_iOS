//
//  BTAchievement+CoreDataProperties.h
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import "BTAchievement+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BTAchievement (CoreDataProperties)

+ (NSFetchRequest<BTAchievement *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *details;
@property (nullable, nonatomic, copy) NSString *key;
@property (nonatomic) int32_t xp;
@property (nonatomic) BOOL completed;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) NSData *colorData;

@end

NS_ASSUME_NONNULL_END
