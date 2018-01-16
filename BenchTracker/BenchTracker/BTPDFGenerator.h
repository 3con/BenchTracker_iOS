//
//  BTPDFGenerator.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BTWorkout;

@interface BTPDFGenerator : NSObject

+ (NSString *)generatePDFWithWorkouts:(NSArray <BTWorkout *> *)workouts;

@end
