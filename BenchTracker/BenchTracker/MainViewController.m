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
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "BTAchievement+CoreDataClass.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic) CGFloat cellHeight;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UIView *noWorkoutsView;
@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) IBOutlet WeekdayView *weekdayView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;

@property (weak, nonatomic) IBOutlet UIButton *blankWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *scanWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *templateButton;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) NSMutableDictionary *exerciseTypeColors;
@property (nonatomic) BTUser *user;

@property (nonatomic) NSDate *firstDay;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.blankWorkoutButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    self.scanWorkoutButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    self.templateButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.user = [BTUser sharedInstance];
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.horizontalPadding = 32;
    style.verticalPadding = 32;
    style.cornerRadius = 12;
    style.imageSize = CGSizeMake(32, 32);
    [CSToastManager setSharedStyle:style];
    [CSToastManager setTapToDismissEnabled:YES];
    [CSToastManager setQueueEnabled:YES];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listTableView.contentInset = UIEdgeInsetsMake(0, 0, 95, 0);
    self.listTableView.separatorInset = UIEdgeInsetsMake(0, 25, 0, 25);
    [self.listTableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIButton *button in @[self.scanWorkoutButton, self.blankWorkoutButton, self.templateButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    self.rightBarButton.layer.cornerRadius = 12;
    self.rightBarButton.clipsToBounds = YES;
    self.settings = [BTSettings sharedInstance];
    self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
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
        [self loadTableViewGradient];
        [self.weekdayView scrollToDate:[NSDate date]];
        [self setUpCalendarView];
        [self.segmentedControlContainerView setNeedsLayout];
        [self.segmentedControlContainerView layoutIfNeeded];
        [self setUpSegmentedControl];
        [self setSelectedViewIndex:0];
    }
}

- (void)loadTableViewGradient {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.startPoint = CGPointMake(0.5,0.0);
    gradientLayer.endPoint = CGPointMake(0.5,1.0);
    gradientLayer.locations = @[@(0.05),
                                @(0.70),
                                @(1.00)];
    gradientLayer.colors =    @[(id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor,
                                (id)[UIColor colorWithWhite:1.0 alpha:0.5].CGColor,
                                (id)[UIColor colorWithWhite:1.0 alpha:1.0].CGColor];
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([BTTutorialManager needsOnboarding]) {
        BTTutorialManager *manager = [[BTTutorialManager alloc] init];
        [self presentViewController:[manager onboardingViewControllerforSize:self.view.frame.size] animated:YES completion:nil];
    }
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
         [self presentUserViewController];
    else [self workoutButtonPressed:sender];
}

- (IBAction)workoutButtonPressed:(UIButton *)sender {
    [self presentWorkoutViewControllerWithWorkout:nil];
}

- (IBAction)scanWorkoutButtonPressed:(UIButton *)sender {
    [self presentQRScannerViewController];
}

- (IBAction)templateButtonPressed:(UIButton *)sender {
    [self presentTemplateSelectionViewController];
}

#pragma mark - FSCalendar

- (void)determineFirstDay {
    if (self.user) {
        NSDate *firstWorkout = [self dateOfFirstWorkout];
        self.firstDay = (!firstWorkout || [firstWorkout compare:self.user.dateCreated] == 1) ? self.user.dateCreated : firstWorkout;
    }
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

- (void)setUpCalendarView {
    self.calendarView.firstWeekday = (self.settings.startWeekOnMonday) ? 2 : 1;
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    self.calendarView.headerHeight = 40;
    self.calendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendarView.calendarWeekdayView.backgroundColor = [UIColor BTPrimaryColor];
    self.calendarView.calendarHeaderView.backgroundColor = [UIColor BTPrimaryColor];
    self.calendarView.appearance.headerTitleFont = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.calendarView.appearance.weekdayFont = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [self.calendarView registerClass:[BTCalendarCell class] forCellReuseIdentifier:@"cell"];
}

#pragma mark - FSCalendar dataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:-75*86400 sinceDate:self.firstDay];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate dateWithTimeInterval:75*86400 sinceDate:[NSDate date]];
}

- (void)configureCell:(BTCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position {
    cell.exerciseTypeColors = self.exerciseTypeColors;
    [cell loadWithWorkouts:[BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]]];
}

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition {
    BTCalendarCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition {
    [self configureCell:(BTCalendarCell *)cell forDate:date atMonthPosition:monthPosition];
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(NSDate *)date {
    return [UIColor clearColor];
}

- (NSArray<UIColor *> *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventDefaultColorsForDate:(NSDate *)date {
    return @[[UIColor BTLightGrayColor]];
}

- (CGPoint)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance eventOffsetForDate:(NSDate *)date {
    return CGPointMake(0, 8);
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date {
    return ([[NSCalendar currentCalendar] isDate:date inSameDayAsDate:[NSDate date]]);
}

#pragma mark - FSCalendar delegate

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
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segmentedControl.layer.cornerRadius = 8;
    self.segmentedControl.clipsToBounds = YES;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedControl.backgroundColor = [UIColor BTSecondaryColor];
    self.segmentedControl.selectionIndicatorBoxOpacity = 1.0;
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor BTTertiaryColor];
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
        [self.rightBarButton setImage:[UIImage imageNamed:@"User"] forState:UIControlStateNormal];
        self.calendarView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 1;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 0;
            self.blankWorkoutButton.alpha = 1;
            self.scanWorkoutButton.alpha = 1;
            self.templateButton.alpha = 1;
            self.rightBarButton.alpha = 1;
        } completion:^(BOOL finished) {
            self.listTableView.userInteractionEnabled = YES;
            self.blankWorkoutButton.userInteractionEnabled = YES;
            self.scanWorkoutButton.userInteractionEnabled = YES;
            self.templateButton.userInteractionEnabled = YES;
        }];
    }
    else if (index == 1) {
        self.rightBarButton.alpha = 0;
        self.rightBarButton.backgroundColor = self.blankWorkoutButton.backgroundColor;
        self.rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.rightBarButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        NSString *text = (self.view.frame.size.width > 400) ? @"New Workout" : @"New";
        [self.rightBarButton setTitle:text forState:UIControlStateNormal];
        [self.rightBarButton setImage:nil forState:UIControlStateNormal];
        self.listTableView.userInteractionEnabled = NO;
        self.calendarView.userInteractionEnabled = NO;
        self.blankWorkoutButton.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        self.templateButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 1;
            self.calendarView.alpha = 0;
            self.blankWorkoutButton.alpha = 0;
            self.scanWorkoutButton.alpha = 0;
            self.templateButton.alpha = 0;
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
        NSString *text = (self.view.frame.size.width > 400) ? @"New Workout" : @"New";
        [self.rightBarButton setTitle:text forState:UIControlStateNormal];
        [self.rightBarButton setImage:nil forState:UIControlStateNormal];
        self.listTableView.userInteractionEnabled = NO;
        self.weekdayContainerView.userInteractionEnabled = NO;
        self.blankWorkoutButton.userInteractionEnabled = NO;
        self.scanWorkoutButton.userInteractionEnabled = NO;
        self.templateButton.userInteractionEnabled = NO;
        [UIView animateWithDuration:.2 animations:^{
            self.listTableView.alpha = 0;
            self.weekdayContainerView.alpha = 0;
            self.calendarView.alpha = 1;
            self.blankWorkoutButton.alpha = 0;
            self.scanWorkoutButton.alpha = 0;
            self.templateButton.alpha = 0;
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
    return self.cellHeight;
}

- (void)configureWorkoutCell:(WorkoutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.settings.exerciseTypeColors)
        cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    cell.delegate = self;
    [cell loadWorkout:[_fetchedResultsController objectAtIndexPath:indexPath]];
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

#pragma mark - MGSwipeTableCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    [(WorkoutTableViewCell *)cell checkTemplateStatus];
    return YES;
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = [self.listTableView indexPathForCell:cell];
    BTWorkout *workout = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (direction == MGSwipeDirectionLeftToRight) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Delete Workout"
                                                                        message:@"Are you sure you want to delete this workout? You will lose all you hard work! This action cannot be undone."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [BTUser removeWorkoutFromTotals:workout];
                [self.context deleteObject:workout];
                [self.context save:nil];
            });
        }];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        CSToastStyle *style = [CSToastManager sharedStyle];
        if ([BTWorkoutTemplate templateExistsForWorkout:workout]) {
            [BTWorkoutTemplate removeWorkoutFromTemplateList:workout];
            style.backgroundColor = [[UIColor BTRedColor] colorWithAlphaComponent:.8];
            [self.view makeToast:nil duration:0.5 position:CSToastPositionCenter title:nil
                           image:[UIImage imageNamed:@"TemplateDelete"] style:style completion:nil];
        }
        else {
            [BTWorkoutTemplate saveWorkoutToTemplateList:workout];
            style.backgroundColor = [[UIColor BTButtonSecondaryColor] colorWithAlphaComponent:.8];
            [self.view makeToast:nil duration:0.5 position:CSToastPositionCenter title:nil
                           image:[UIImage imageNamed:@"TemplateAdd"] style:nil completion:nil];
        }
    }
    return YES;
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
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionLeft;
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

- (void)presentTemplateSelectionViewController {
    TemplateSelectionViewController *tsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ts"];
    tsVC.delegate = self;
    tsVC.context = self.context;
    tsVC.settings = self.settings;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:tsVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    tsVC.transitioningDelegate = self.animator;
    tsVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:tsVC animated:YES completion:nil];
}

- (void)presentUserViewController {
    UserViewController *userVC = [self.storyboard instantiateViewControllerWithIdentifier:@"us"];
    userVC.delegate = self;
    userVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:userVC];
    self.animator.bounces = NO;
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    userVC.transitioningDelegate = self.animator;
    userVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:userVC animated:YES completion:nil];
}

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {
    [self.calendarView reloadData];
    [self.weekdayView reloadData];
}

#pragma mark - settingsVC delegate

- (void)userViewControllerSettingsDidUpdate:(UserViewController *)userVC {
    self.cellHeight = 0;
    [self.listTableView reloadData];
    [self.weekdayView reloadData];
    self.calendarView.firstWeekday = (self.settings.startWeekOnMonday) ? 2 : 1;
    [self.calendarView reloadData];
}

#pragma mark - workoutSelectionVC delegate

- (void)workoutSelectionVC:(WorkoutSelectionViewController *)wsVC didDismissWithSelectedWorkout:(BTWorkout *)workout {
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - templateSelectionVC delegate

- (void)templateSelectionViewController:(TemplateSelectionViewController *)tsVC didDismissWithSelectedWorkout:(BTWorkout *)workout {
    [self presentWorkoutViewControllerWithWorkout:workout];
    [BTAchievement markAchievementComplete:ACHIEVEMENT_TEMPLATE animated:YES];
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

- (CGFloat)cellHeight {
    if (_cellHeight == 0) _cellHeight = [WorkoutTableViewCell heightForWorkoutCell];
    return _cellHeight;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
