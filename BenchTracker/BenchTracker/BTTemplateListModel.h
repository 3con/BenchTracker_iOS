//
//  BTTemplateListModel.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/9/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "BTWorkoutTemplateModel.h"

@interface BTTemplateListModel : JSONModel

@property (nonatomic) NSMutableArray<BTWorkoutTemplateModel *> <BTWorkoutTemplateModel> *userWorkouts;

@property (nonatomic) NSMutableArray<BTWorkoutTemplateModel *> <BTWorkoutTemplateModel> *defaultWorkouts;

@end
