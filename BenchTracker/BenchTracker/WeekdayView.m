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

@interface WeekdayView ()

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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self loadTitleView];
}

- (void)reloadData {
    NSDateComponents* comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
    self.firstDayOfWeekDate = [NSDate dateWithTimeIntervalSinceNow:offset*86400];
    comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self.user.dateCreated];
    offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
    self.firstDayDate = [self.user.dateCreated dateByAddingTimeInterval:offset*86400-70*86400];
    [self.tableView reloadData];
}

- (void)scrollToDate:(NSDate *)date {
    NSDateComponents* comp = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:date];
    NSInteger offset = (comp.weekday != 1) ? -(comp.weekday-2) : -6;
    NSDate *targetDate = [date dateByAddingTimeInterval:offset*86400];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:
        [targetDate timeIntervalSinceDate:self.firstDayDate]/86400 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 70+[self.firstDayOfWeekDate timeIntervalSinceDate:self.firstDayDate]/86400+70; //10 weeks before, 10 weeks after
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableView.frame.size.height/7.0;
}

- (void)configureWeekdayCell:(WeekdayTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    //BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    //cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    //[cell loadWorkout:workout];
    [cell loadDate:[self.firstDayDate dateByAddingTimeInterval:86400*indexPath.row]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WeekdayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"WeekdayTableViewCell" owner:nil options:nil].firstObject;
    [self configureWeekdayCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    //[self.workoutManager deleteWorkout:workout];
    //[self presentWorkoutViewControllerWithWorkout:workout];
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
            l.textColor = [UIColor whiteColor];
            l.textAlignment = NSTextAlignmentCenter;
            l.font = [UIFont systemFontOfSize:19 weight:UIFontWeightRegular];
            [self.titleView addSubview:l];
        }
    }
    [self updateTitles];
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

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
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
