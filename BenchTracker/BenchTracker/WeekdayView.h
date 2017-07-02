//
//  WeekdayView.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTUser;

@interface WeekdayView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) BTUser *user;
@property (nonatomic) NSManagedObjectContext *context;

- (void)reloadData;

- (void)scrollToDate:(NSDate *)date;

@end
