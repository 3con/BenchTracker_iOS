//
//  BTDataTransferModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "BTUserModel.h"
#import "BTSettingsModel.h"
#import "BTTypeListModel.h"
#import "BTWorkoutModel.h"

@interface BTDataTransferModel : JSONModel

@property (nonatomic) NSInteger version;
@property (nonatomic) BTUserModel *user;
@property (nonatomic) BTSettingsModel *settings;
@property (nonatomic) BTTypeListModel *typeList;
@property (nonatomic) NSMutableArray <BTWorkoutModel *> <BTWorkoutModel> *workouts;

@end
