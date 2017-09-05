//
//  BTAchievement+CoreDataClass.m
//  
//
//  Created by Chappy Asel on 9/5/17.
//
//

#import "BTAchievement+CoreDataClass.h"

@implementation BTAchievement

- (void)setImage:(UIImage *)image {
    self.imageData = UIImagePNGRepresentation(image);
}

- (UIImage *)image {
    return [UIImage imageWithData:self.imageData];
}

- (void)setColor:(UIColor *)color {
    self.colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
}

- (UIColor *)color {
    return [NSKeyedUnarchiver unarchiveObjectWithData:self.colorData];
}

@end
