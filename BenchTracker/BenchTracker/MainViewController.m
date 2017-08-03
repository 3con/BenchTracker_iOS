//
//  MainViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/27/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "MainViewController.h"
#import "BTSettings+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"
#import "AppDelegate.h"
#import "WorkoutTableViewCell.h"
#import "WeekdayTableViewCell.h"
#import "HMSegmentedControl.h"
#import "BTTutorialManager.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (weak, nonatomic) IBOutlet UIView *noWorkoutsView;
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet WeekdayView *weekdayView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@property (weak, nonatomic) IBOutlet UIButton *blankWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *scanWorkoutButton;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) BTUser *user;

@property (nonatomic) NSDate *firstDay;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.blankWorkoutButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    self.scanWorkoutButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.user = [BTUser sharedInstance];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listTableView.contentInset = UIEdgeInsetsMake(0, 0, 95, 0);
    [self.listTableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIButton *button in @[self.scanWorkoutButton, self.blankWorkoutButton, self.rightBarButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
    }
    self.scanWorkoutButton.imageEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    self.settings = [BTSettings sharedInstance];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.weekdayView) { //first load
        [self determineFirstDay];
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
    if ([BTTutorialManager needsOnboarding])
        [self presentViewController:[BTTutorialManager onboardingVC] animated:YES completion:nil];
    if (self.settings.activeWorkout)
        [self presentWorkoutViewControllerWithWorkout:self.settings.activeWorkout];
}

- (void)loadUser {
    self.weekdayView.user = self.user;
    [self.weekdayView reloadData];
}

- (IBAction)analyicsButtonPressed:(UIButton *)sender {
    [self presentAnalyticsViewController];
}

- (IBAction)rightBarButtonPressed:(UIButton *)sender {
    if(self.segmentedControl.selectedSegmentIndex == 0)
         [self presentSettingsViewController];
    else [self workoutButtonPressed:sender];
}

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    [self presentWorkoutViewControllerWithWorkout:nil];
}

- (IBAction)scanWorkoutButtonPressed:(UIButton *)sender {
    [self presentQRScannerViewController];
}

#pragma mark - calendarView

- (void)determineFirstDay {
    if (self.user) {
        NSDate *firstWorkout = [self dateOfFirstWorkout];
        self.firstDay = (!firstWorkout || [firstWorkout compare:self.user.dateCreated] == 1) ? self.user.dateCreated : firstWorkout;
    }
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

- (void)setUpCalendarView {
    self.calendarView.firstWeekday = (self.settings.startWeekOnMonday) ? 2 : 1;
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    self.calendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendarView.calendarWeekdayView.backgroundColor = [UIColor BTPrimaryColor];
    self.calendarView.calendarHeaderView.backgroundColor = [UIColor BTPrimaryColor];
}

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:-75*86400 sinceDate:self.firstDay];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:75*86400 sinceDate:[NSDate date]];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    if ([BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0)
        return [UIColor BTTertiaryColor];
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    return [UIColor BTPrimaryColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    if ([date compare:self.calendarView.maximumDate] == NSOrderedDescending ||
        [date compare:self.calendarView.minimumDate] == NSOrderedAscending) return [UIColor whiteColor];
    else if ([date compare:[NSDate date]] == NSOrderedDescending ||
             [date compare:[self.firstDay dateByAddingTimeInterval:-86400]] == NSOrderedAscending) return [UIColor lightGrayColor];
    else if ([BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0)
        return [UIColor whiteColor];
    return [UIColor BTPrimaryColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    return @[[UIColor BTPrimaryColor]];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date {
    return @[[UIColor BTSecondaryColor]];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    if ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:[NSDate date]]) return 1;
    return 0;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    CGRect frame = [calendar frameForDate:date];
    CGPoint point = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y+frame.size.height/2.0);
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
    self.segmentedControl.backgroundColor = [UIColor BTSecondaryColor];
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
        self.rightBarButton.alpha = 0;
        self.rightBarButton.backgroundColor = [UIColor clearColor];
        self.rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.rightBarButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [self.rightBarButton setTitle:@"" forState:UIControlStateNormal];
        [self.rightBarButton setImage:[UIImage imageNamed:@"Settings"] forState:UIControlStateNormal];
        self.calendarView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 1;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 0;
            self.blankWorkoutButton.alpha = 1;
            self.scanWorkoutButton.alpha = 1;
            self.rightBarButton.alpha = 1;
        } completion:^(BOOL finished) {
            self.listTableView.userInteractionEnabled = YES;
            self.blankWorkoutButton.userInteractionEnabled = YES;
            self.scanWorkoutButton.userInteractionEnabled = YES;
        }];
    }
    else if (index == 1) {
        self.rightBarButton.alpha = 0;
        self.rightBarButton.backgroundColor = self.blankWorkoutButton.backgroundColor;
        self.rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.rightBarButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [self.rightBarButton setTitle:@"New Workout" forState:UIControlStateNormal];
        [self.rightBarButton setImage:nil forState:UIControlStateNormal];
        self.listTableView.userInteractionEnabled = NO;
        self.calendarView.userInteractionEnabled = NO;
        self.blankWorkoutButton.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 1;
            self.calendarView.alpha = 0;
            self.blankWorkoutButton.alpha = 0;
            self.scanWorkoutButton.alpha = 0;
            self.rightBarButton.alpha = 1;
        } completion:^(BOOL finished) {
            self.weekdayContainerView.userInteractionEnabled = YES;
        }];
    }
    else {
        self.rightBarButton.alpha = 0;
        self.rightBarButton.backgroundColor = self.blankWorkoutButton.backgroundColor;
        self.rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.rightBarButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [self.rightBarButton setTitle:@"New Workout" forState:UIControlStateNormal];
        [self.rightBarButton setImage:nil forState:UIControlStateNormal];
        self.listTableView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        self.blankWorkoutButton.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 1;
            self.blankWorkoutButton.alpha = 0;
            self.scanWorkoutButton.alpha = 0;
            self.rightBarButton.alpha = 1;
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
    NSInteger num = [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
    self.noWorkoutsView.userInteractionEnabled = (num == 0);
    [UIView animateWithDuration:.25 animations:^{
        self.noWorkoutsView.alpha = (num == 0);
    }];
    return num;
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
    [self.context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    [self.context save:nil];
}

#pragma mark - weekdayView delegate

- (void)weekdayView:(WeekdayView *)weekdayView userSelectedDate:(NSDate *)date atPoint:(CGPoint)point {
    [self presentWorkoutSelectionViewControllerWithOriginPoint:point date:date];
}

#pragma mark - QRScanner delegate

- (void)qrScannerVC:(BTQRScannerViewController *)qrVC didDismissWithScannedString:(NSString *)string {
    BTWorkout *workout = [BTWorkout workoutForJSON:string];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - view handling

- (void)presentAnalyticsViewController {
    AnalyticsViewController *analyiticsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"a"];
    analyiticsVC.delegate = self;
    analyiticsVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:analyiticsVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    analyiticsVC.transitioningDelegate = self.animator;
    analyiticsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:analyiticsVC animated:YES completion:nil];
}

- (void)presentWorkoutViewControllerWithWorkout:(BTWorkout *)workout {
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
    wsVC.delegate = self;
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

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {
    [self.context save:nil];
    [self.calendarView reloadData];
    [self.weekdayView reloadData];
}

#pragma mark - settingsVC delegate

- (void)settingsViewWillDismiss:(SettingsViewController *)settingsVC {
    [self.weekdayView reloadData];
    self.calendarView.firstWeekday = (self.settings.startWeekOnMonday) ? 2 : 1;
    [self.calendarView reloadData];
}

#pragma mark - workoutSelectionVC delegate

- (void)workoutSelectionVC:(WorkoutSelectionViewController *)wsVC didDismissWithSelectedWorkout:(BTWorkout *)workout {
    [self presentWorkoutViewControllerWithWorkout:workout];
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
        case NSFetchedResultsChangeUpdate: break;
        case NSFetchedResultsChangeMove: break;
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

@end
