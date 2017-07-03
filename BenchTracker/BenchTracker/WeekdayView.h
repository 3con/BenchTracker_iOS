//
//  WeekdayView.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTUser;
@class BTWorkoutManager;
@class BTSettings;

@interface WeekdayView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTUser *user;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTWorkoutManager *workoutManager;

- (void)reloadData;

- (void)scrollToDate:(NSDate *)date;

@end
