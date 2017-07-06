//
//  MainViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "MainViewController.h"
#import "BTUserManager.h"
#import "BTWorkoutManager.h"
#import "ZFModalTransitionAnimator.h"
#import "AppDelegate.h"
#import "WorkoutTableViewCell.h"
#import "WeekdayTableViewCell.h"
#import "HMSegmentedControl.h"

@interface MainViewController ()

@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTUserManager *userManager;
@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTUser *user;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.userManager = [BTUserManager sharedInstance];
    self.user = [self.userManager user];
    self.workoutManager = [BTWorkoutManager sharedInstance];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    [self.listTableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scanWorkoutButton.layer.cornerRadius = 12;
    self.scanWorkoutButton.clipsToBounds = YES;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTSettings"];
    NSError *error;
    self.settings = [self.context executeFetchRequest:fetchRequest error:&error].firstObject;
    if (error) NSLog(@"settings fetcher errror: %@",error);
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.weekdayView) { //first load
        self.weekdayView = [[NSBundle mainBundle] loadNibNamed:@"WeekdayView" owner:self options:nil].firstObject;
        self.weekdayView.delegate = self;
        self.weekdayView.context = self.context;
        self.weekdayView.settings = self.settings;
        self.weekdayView.workoutManager = self.workoutManager;
        self.weekdayView.frame = CGRectMake(0, 0, self.weekdayContainerView.frame.size.width, self.weekdayContainerView.frame.size.height);
        [self.weekdayContainerView addSubview:self.weekdayView];
        [self loadUser];
        [self.weekdayView scrollToDate:[NSDate date]];
        [self setUpCalendarView];
        [self.segmentedControlContainerView setNeedsLayout];
        [self.segmentedControlContainerView layoutIfNeeded];
        [self setUpSegmentedControl];
        [self setSelectedViewIndex:0];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.user) { //No user in CoreData
        [self presentLoginViewController];
    }
    [self.userManager setAutoRefresh:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.userManager setAutoRefresh:NO];
}

- (void)loadUser {
    self.weekdayView.user = self.user;
    [self.weekdayView reloadData];
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
}

- (IBAction)scanWorkoutButtonPressed:(UIButton *)sender {
    /*
    MMScannerController *scanner = [[MMScannerController alloc] init];
    scanner.showGalleryOption = NO;
    scanner.showFlashlight = NO;
    scanner.supportBarcode = NO;
    [scanner setCompletion:^(NSString *scanConetent) {
        NSLog(@"%@",scanConetent);
    }];
    [self presentViewController:scanner animated:YES completion:^{
        
    }];
     */
    [self presentQRScannerViewController];
}

#pragma mark - calendarView

- (void)setUpCalendarView {
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    self.calendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendarView.calendarWeekdayView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
    self.calendarView.calendarHeaderView.backgroundColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:-75*86400 sinceDate:self.user.dateCreated];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:75*86400 sinceDate:[NSDate date]];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    if ([self.workoutManager workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0)
        return [UIColor colorWithRed:67/255.0 green:160/255.0 blue:71/255.0 alpha:1];
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    return [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    if ([date compare:self.calendarView.maximumDate] == NSOrderedDescending ||
        [date compare:self.calendarView.minimumDate] == NSOrderedAscending) return [UIColor whiteColor];
    else if ([date compare:[NSDate date]] == NSOrderedDescending ||
             [date compare:[self.user.dateCreated dateByAddingTimeInterval:-86400]] == NSOrderedAscending) return [UIColor lightGrayColor];
    else if ([self.workoutManager workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0)
        return [UIColor whiteColor];
    return [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    return @[[UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1]];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date {
    return @[[UIColor colorWithRed:30/255.0 green:30/255.0 blue:120/255.0 alpha:1]];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    if ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:[NSDate date]]) return 1;
    return 0;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CGRect frame = [calendar frameForDate:date];
    CGPoint point = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y+frame.size.height/2.0+self.calendarView.frame.origin.y);
    [self presentWorkoutSelectionViewControllerWithOriginPoint:point date:date];
    return NO;
}

#pragma mark - segmedtedControl

- (void)setUpSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"List", @"Week", @"Month"]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.segmentedControlContainerView.frame.size.width,
                                             self.segmentedControlContainerView.frame.size.height);
    self.segmentedControl.layer.cornerRadius = 8;
    self.segmentedControl.clipsToBounds = YES;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedControl.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:120/255.0 alpha:1];
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
    self.segmentedControl.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor whiteColor], NSForegroundColorAttributeName,
                                                 [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
    self.segmentedControl.selectedTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                                         [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlContainerView addSubview:self.segmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self setSelectedViewIndex:self.segmentedControl.selectedSegmentIndex];
}

- (void)setSelectedViewIndex:(NSInteger)index {
    if (index == 0) {
        self.calendarView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 1;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 0;
            self.scanWorkoutButton.alpha = 1;
        } completion:^(BOOL finished) {
            self.listTableView.userInteractionEnabled = YES;
            self.scanWorkoutButton.userInteractionEnabled = YES;
        }];
    }
    else if (index == 1) {
        self.listTableView.userInteractionEnabled = NO;
        self.calendarView.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 1;
            self.calendarView.alpha = 0;
            self.scanWorkoutButton.alpha = 0;
        } completion:^(BOOL finished) {
            self.weekdayContainerView.userInteractionEnabled = YES;
        }];
    }
    else {
        self.listTableView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 1;
            self.scanWorkoutButton.alpha = 0;
        } completion:^(BOOL finished) {
            self.calendarView.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"BTWorkout" inManagedObjectContext:self.context]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
                                                               initWithFetchRequest:fetchRequest managedObjectContext:self.context
                                                               sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)configureWorkoutCell:(WorkoutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (self.settings.exerciseTypeColors)
        cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    cell.delegate = self;
    [cell loadWorkout:workout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureWorkoutCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    //[self.workoutManager deleteWorkout:workout];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

#pragma mark - SWTableViewCell delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *indexPath = [self.listTableView indexPathForCell:cell];
    [self.workoutManager deleteWorkout:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

#pragma mark - weekdayView delegate

- (void)weekdayView:(WeekdayView *)weekdayView userSelectedDate:(NSDate *)date atPoint:(CGPoint)point {
    [self presentWorkoutSelectionViewControllerWithOriginPoint:point date:date];
}

#pragma mark - QRScanner delegate

- (void)qrScannerVC:(BTQRScannerViewController *)qrVC didDismissWithScannedString:(NSString *)string {
    BTWorkout *workout = [self.workoutManager createWorkoutWithJSON:string];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - view handling

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    [self presentWorkoutViewControllerWithWorkout:nil];
}

- (void)presentLoginViewController {
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"l"];
    loginVC.delegate = self;
    loginVC.userManager = self.userManager;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:loginVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    loginVC.transitioningDelegate = self.animator;
    loginVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:loginVC animated:YES completion:nil];
}

- (void)presentSettingsViewController {
    SettingsViewController *settingsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"s"];
    settingsVC.delegate = self;
    settingsVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:settingsVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    settingsVC.transitioningDelegate = self.animator;
    settingsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (void)presentWorkoutViewControllerWithWorkout: (BTWorkout *)workout {
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"w"];
    workoutVC.delegate = self;
    workoutVC.context = self.context;
    workoutVC.workout = workout;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:workoutVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    workoutVC.transitioningDelegate = self.animator;
    workoutVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:workoutVC animated:YES completion:nil];
}

- (void)presentWorkoutSelectionViewControllerWithOriginPoint:(CGPoint)point date:(NSDate *)date {
    WorkoutSelectionViewController *wsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ws"];
    wsVC.context = self.context;
    wsVC.workoutManager = self.workoutManager;
    wsVC.date = date;
    wsVC.originPoint = point;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:wsVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    wsVC.transitioningDelegate = self.animator;
    wsVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:wsVC animated:YES completion:nil];
}

- (void)presentQRScannerViewController {
    BTQRScannerViewController *qrVC = [[NSBundle mainBundle] loadNibNamed:@"BTQRScannerViewController" owner:self options:nil].firstObject;
    qrVC.delegate = self;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:qrVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    qrVC.transitioningDelegate = self.animator;
    qrVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:qrVC animated:YES completion:nil];
}

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {
    if (workout) [self.workoutManager saveEditedWorkout:workout];
    [self.calendarView reloadData];
    [self.weekdayView reloadData];
}

#pragma mark - settingsVC delegate

- (void)settingsViewControllerDidRequestUserLogout:(SettingsViewController *)settingsVC {
    self.user = nil;
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] resetCoreData];
}

#pragma mark - loginVC delegate

- (void)loginViewController:(LoginViewController *)loginVC willDismissWithUser:(BTUser *)user {
    self.user = user;
    [self loadUser];
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.listTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.listTableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureWorkoutCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.listTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.listTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.listTableView endUpdates];
    [self.weekdayView reloadData];
    [self.calendarView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
