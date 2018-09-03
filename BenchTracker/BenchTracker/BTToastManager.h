//
//  BTToastManager.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/3/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTAchievement;

@interface BTToastManager : NSObject

+ (void)setUpToasts;

+ (void)presentToastForAchievement:(BTAchievement *)achievement;

+ (void)presentToastForTemplate:(BOOL)isAddition;

@end
