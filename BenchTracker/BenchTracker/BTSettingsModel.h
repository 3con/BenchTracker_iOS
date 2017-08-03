//
//  BTSettingsModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface BTSettingsModel : JSONModel

@property (nonatomic) BOOL startWeekOnMonday;
@property (nonatomic) BOOL disableSleep;
@property (nonatomic) BOOL weightInLbs;

@end
