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
@class WeekdayTableViewCell;
@protocol MGSwipeTableCellDelegate;

@class WeekdayView;

@protocol WeekdayViewDelegate <NSObject>
- (void)weekdayView:(WeekdayView *)weekdayView userSelectedDate:(NSDate *)date atPoint:(CGPoint)point;
@end

@interface WeekdayView : UIView <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) id<WeekdayViewDelegate, MGSwipeTableCellDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTUser *user;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTWorkoutManager *workoutManager;

- (void)reloadData;

- (void)scrollToDate:(NSDate *)date;

//3D Touch

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;

- (WeekdayTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)sourceRectForIndex:(NSIndexPath *)indexPath;

@end
