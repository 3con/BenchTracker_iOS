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
#import "HMSegmentedControl.h"

@interface MainViewController ()

@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTUserManager *userManager;
@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.userManager = [BTUserManager sharedInstance];
    self.workoutManager = [BTWorkoutManager sharedInstance];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self setUpSegmentedControl];
    [self setUpCalendarView];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self setSelectedViewIndex:0];
    [super viewWillAppear:animated];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTSettings"];
    NSError *error;
    self.settings = [self.context executeFetchRequest:fetchRequest error:&error].firstObject;
    if (error) NSLog(@"settings fetcher errror: %@",error);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![self.userManager user]) { //No user in CoreData
        [self presentLoginViewController];
    }
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self presentSettingsViewController];
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
    return [NSDate dateWithTimeIntervalSince1970:31536000*47.034];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:86400 sinceDate:[NSDate date]];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillSelectionColorForDate:(NSDate *)date {
    return [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date {
    return [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleSelectionColorForDate:(NSDate *)date {
    return [UIColor whiteColor];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    return @[[UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1]];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventSelectionColorsForDate:(nonnull NSDate *)date {
    return @[[UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1]];
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    if ([[self normalizedDateForDate:[NSDate date]] compare:date] == NSOrderedSame) return 1; //same day
    return 0;
}

- (NSDate *)normalizedDateForDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit preservedComponents = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    NSDateComponents *components = [calendar components:preservedComponents fromDate:date];
    return [calendar dateFromComponents:components];
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
        [UIView animateWithDuration:.2 animations:^{
            self.tableView.alpha = 1;
            self.calendarView.alpha = 0;
        } completion:^(BOOL finished) {
            self.tableView.userInteractionEnabled = YES;
        }];
    }
    else {
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.tableView.alpha = 0;
            self.calendarView.alpha = 1;
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

- (void)configureCell:(WorkoutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    [cell loadWorkout:workout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"WorkoutTableViewCell" owner:nil options:nil].firstObject;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    //[self.workoutManager deleteWorkout:workout];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - view handling

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    [self presentWorkoutViewControllerWithWorkout:nil];
}

- (void)presentLoginViewController {
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"l"];
    loginVC.userManager = self.userManager;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:loginVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.75;
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
    self.animator.transitionDuration = 0.75;
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

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {
    if (workout) [self.workoutManager saveEditedWorkout:workout];
}

#pragma mark - settingsVC delegate

- (void)settingsViewControllerDidRequestUserLogout:(SettingsViewController *)settingsVC {
    [self.context deleteObject:[self.userManager user]];
    //DELETE ALL WORKOUTS
    //DELETE SETTINGS
    //DELETE EXERCISE TYPES
    [self.context save:nil];
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
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
