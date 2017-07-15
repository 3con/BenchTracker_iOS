//
//  ADMuscleSplitViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADMuscleSplitViewController.h"
#import "ADMuscleSplitTableViewCell.h"
#import "BTUserManager.h"
#import "BTWorkoutManager.h"

@interface ADMuscleSplitViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTUser *user;

@property (nonatomic) NSDate *firstDayDate;
@property (nonatomic) NSDate *firstDayOfWeekDate;

@end

@implementation ADMuscleSplitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.user = [(BTUserManager *)[BTUserManager sharedInstance] user];
    self.workoutManager = [BTWorkoutManager sharedInstance];
    [self loadWeekLogic];
    self.titleString = @"Muscle Split";
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
    self.firstDayDate = [dayOfFirst dateByAddingTimeInterval:offset*86400];
}

- (NSDate *)dateOfFirstWorkout {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkout"];
    request.fetchBatchSize = 11;
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

- (NSArray <BTWorkout *> *)workoutsForIndexPath:(NSIndexPath *)indexPath {
    return [self.workoutManager workoutsBetweenBeginDate:[self.firstDayOfWeekDate dateByAddingTimeInterval:-86400*7*indexPath.row]
                                              andEndDate:[self.firstDayOfWeekDate dateByAddingTimeInterval:-86400*7*(indexPath.row-1)]];
}

#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.firstDayOfWeekDate timeIntervalSinceDate:self.firstDayDate]/86400/7+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 210;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADMuscleSplitTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ADMuscleSplitTableViewCell" owner:self options:nil].firstObject;
        cell.color = self.color;
    }
    [cell loadWithDate:[self.firstDayOfWeekDate dateByAddingTimeInterval:-86400*7*indexPath.row]
              workouts:[self workoutsForIndexPath:indexPath] weightSuffix:self.settings.weightSuffix];
    return cell;
}

#pragma mark - tableView delegate

@end
