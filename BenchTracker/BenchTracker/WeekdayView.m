//
//  WeekdayView.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WeekdayView.h"
#import "BTUser+CoreDataClass.h"
#import "WeekdayTableViewCell.h"
#import "BTSettings+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"

@interface WeekdayView ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (nonatomic) IBOutlet UIView *titleView;
@property (nonatomic) NSArray <UILabel *> *titleViews;
@property (nonatomic) NSArray <NSString *> *titleArray;
@property (nonatomic) int currentTabIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSDate *firstDayDate;
@property (nonatomic) NSDate *firstDayOfWeekDate;

@end

@implementation WeekdayView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadTitleView];
}

- (void)reloadData {
    if (self.user) {
        [self loadWeekLogic];
        [self.tableView reloadData];
        [self updateTitles];
        [self scrollViewDidScroll:self.tableView];
    }
}

- (void)loadWeekLogic {
    NSDate *today = [self normalizedDateForDate:[NSDate date]];
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:today];
    NSInteger offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
    if (!self.settings.startWeekOnMonday) offset = (comp.weekday != 1) ? -(comp.weekday-1) : 0;
    self.firstDayOfWeekDate = [today dateByAddingTimeInterval:offset*86400];
    NSDate *firstWorkout = [self dateOfFirstWorkout];
    NSDate *firstDate = (!firstWorkout || [firstWorkout compare:self.user.dateCreated] == 1) ? self.user.dateCreated : firstWorkout;
    comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:firstDate];
    offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
    if (!self.settings.startWeekOnMonday) offset = (comp.weekday != 1) ? -(comp.weekday-1) : 0;
    NSDate *dayOfFirst = [self normalizedDateForDate:firstDate];
    self.firstDayDate = [dayOfFirst dateByAddingTimeInterval:offset*86400-35*86400];
}

- (NSDate *)dateOfFirstWorkout {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    request.fetchBatchSize = 1;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    NSError *error;
    NSArray <BTWorkout *> *arr = [self.context executeFetchRequest:request error:&error];
    if (error) NSLog(@"muscle split error: %@",error);
    return (arr && arr.count > 0) ? arr.firstObject.date : nil;
}

- (NSDate *)normalizedDateForDate:(NSDate *)date {
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                 fromDate:date];
    return [NSCalendar.currentCalendar dateFromComponents:components];
}

- (void)scrollToDate:(NSDate *)date {
    if (self.user) {
        NSDateComponents *comp = [NSCalendar.currentCalendar components:NSCalendarUnitWeekday fromDate:date];
        NSInteger offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
        if (!self.settings.startWeekOnMonday) offset = (comp.weekday != 1) ? -(comp.weekday-1) : 0;
        date = [date dateByAddingTimeInterval:offset*86400];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(int)[date timeIntervalSinceDate:self.firstDayDate]/86400 inSection:0]
                                    animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self updateTitles];
        [self scrollViewDidScroll:self.tableView];
    }
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point {
    return [self.tableView indexPathForRowAtPoint:[self.tableView convertPoint:point fromView:self]];
}

- (WeekdayTableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellForRowAtIndexPath:indexPath];
}

- (CGRect)sourceRectForIndex:(NSIndexPath *)indexPath {
    return [self convertRect:[self.tableView cellForRowAtIndexPath:indexPath].frame fromView:self.tableView];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.user) return 35+(int)[self.firstDayOfWeekDate timeIntervalSinceDate:self.firstDayDate]/86400+35; //5 weeks before, 5 weeks after
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height/7.0;
}

- (void)configureWeekdayCell:(WeekdayTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self.firstDayDate dateByAddingTimeInterval:86400*indexPath.row];
    cell.today = [[NSCalendar currentCalendar] isDate:date inSameDayAsDate:[NSDate date]];
    if (self.settings.exerciseTypeColors)
        cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    [cell loadWithWorkouts:[BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]]];
    cell.date = date;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeekdayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"WeekdayTableViewCell" owner:nil options:nil].firstObject;
    [self configureWeekdayCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self.firstDayDate dateByAddingTimeInterval:86400*indexPath.row];
    CGRect frame = [tableView rectForRowAtIndexPath:indexPath];
    CGFloat offset = self.tableView.contentOffset.y-self.frame.origin.y-self.superview.frame.origin.y;
    CGPoint point = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y+frame.size.height/2.0-offset);
    [self.delegate weekdayView:self userSelectedDate:date atPoint:point];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

#pragma mark - scrollview delegate, title methods

- (void)loadTitleView {
    self.titleArray = [[NSArray alloc] initWithObjects:@"", @"", @"", nil];
    if (!self.titleViews) {
        self.titleView.clipsToBounds = YES;
        self.titleViews = @[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)],
                            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)],
                            [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)]];
        for (UILabel *l in self.titleViews) {
            l.textColor = [UIColor BTTextPrimaryColor];
            l.textAlignment = NSTextAlignmentCenter;
            l.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
            [self.titleView addSubview:l];
        }
    }
}

- (void)updateTitles {
    self.currentTabIndex = (int)self.tableView.contentOffset.y/self.tableView.frame.size.height;
    NSDateFormatter *firstFormatter = [[NSDateFormatter alloc] init];
    firstFormatter.dateFormat = @"MMM d";
    NSDateFormatter *secondFormatter = [[NSDateFormatter alloc] init];
    secondFormatter.dateFormat = @"MMM d, yyyy";
    NSDate *baseDate = [self.firstDayDate dateByAddingTimeInterval:86400*7*self.currentTabIndex];
    NSMutableArray *labelText = [[NSMutableArray alloc] initWithArray:@[@"", @"", @""]];
    for (int i = -1; i <= 1; i++) {
        labelText[i+1] = [NSString stringWithFormat:@"%@ - %@",
                          [firstFormatter stringFromDate:[baseDate dateByAddingTimeInterval:86400*7*i]],
                          [secondFormatter stringFromDate:[baseDate dateByAddingTimeInterval:86400*7*i+86400*6]]];
    }
    if (self.currentTabIndex == 0) self.titleArray = @[@"", labelText[1], labelText[2]];
    else if (self.currentTabIndex == [self.tableView numberOfRowsInSection:0]-1) self.titleArray = @[labelText[0], labelText[1], @""];
    else self.titleArray = @[labelText[0],labelText[1],labelText[2]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float center = 40;
    float page = self.tableView.contentOffset.y/self.tableView.frame.size.height;
    float dist = page-self.currentTabIndex; // -1 to 1
    for (int i = 0; i < self.titleViews.count; i++) {
        UILabel *label = self.titleViews[i];
        label.text = self.titleArray[i];
        if (i == 0) {
            label.alpha = (dist < 0) ? -dist : 0; //-1 = 1, 0 = 0, 1 = 0
            label.frame = CGRectMake(0, -center+center*(-dist), 300, 40);
        }
        if (i == 1) {
            label.alpha = 1-fabs(dist); //-1 = 1, 0 = 0, 1 = 0
            label.frame = CGRectMake(0, -center*(dist), 300, 40);
        }
        if (i == 2) {
            label.alpha = (dist > 0) ? dist : 0; //-1 = 0, 0 = 0, 1 = 1
            label.frame = CGRectMake(0, center-center*(dist), 300, 40);
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.currentTabIndex = (int)self.tableView.contentOffset.y/self.tableView.frame.size.height;
    [self updateTitles];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
