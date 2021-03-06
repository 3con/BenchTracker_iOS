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
#import "WZLBadgeImport.h"
#import "Appirater.h"
#import "FSCalendarCollectionView.h"
#import "WeekdayTableViewCell.h"

@interface MainViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;

@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (nonatomic) CGFloat cellHeight;
@property (nonatomic) UISearchBar *searchBar;
@property (nonatomic) NSString *searchString;
@property (weak, nonatomic) IBOutlet UIView *gradientView;

@property (strong, nonatomic) IBOutlet UIView *noWorkoutsView;
@property (weak, nonatomic) IBOutlet UILabel *nWTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nWDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nWDescriptionImageView;

@property (weak, nonatomic) IBOutlet UIView *weekdayContainerView;
@property (weak, nonatomic) WeekdayView *weekdayView;
@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;
@property (nonatomic) BOOL firstLoad;

@property (nonatomic, strong) id previewingContext;

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

@property (nonatomic) UIImpactFeedbackGenerator *feedbackImpact;
@property (nonatomic) UISelectionFeedbackGenerator *feedbackSelection;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstLoad = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorSchemeChange:)
                                                 name:@"colorSchemeChange" object:nil];
    [self updateInterface];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.user = [BTUser sharedInstance];
    [BTToastManager setUpToasts];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    self.listTableView.dataSource = self;
    self.listTableView.delegate = self;
    self.listTableView.contentInset = UIEdgeInsetsMake(0, 0, 95, 0);
    self.listTableView.separatorInset = UIEdgeInsetsMake(0, 25, 0, 25);
    [self.listTableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    if ([self isForceTouchAvailable])
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    self.feedbackImpact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    self.feedbackSelection = [[UISelectionFeedbackGenerator alloc] init];
    [Log event:@"MainVC: Loaded" properties:nil];
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[WorkoutViewController class]]) return nil;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    WorkoutViewController *wVC = [storyboard instantiateViewControllerWithIdentifier:@"w"];
    wVC.delegate = self;
    wVC.context = self.context;
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (location.y > self.view.frame.size.height-100) return nil;
        CGPoint cellPostion = [self.listTableView convertPoint:location fromView:self.view];
        NSIndexPath *path = [self.listTableView indexPathForRowAtPoint:cellPostion];
        if (!path) return nil;
        WorkoutTableViewCell *cell = [self.listTableView cellForRowAtIndexPath:path];
        wVC.workout = cell.workout;
        previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:self.listTableView];
    }
    else if (self.segmentedControl.selectedSegmentIndex == 1) {
        CGPoint cellPostion = [self.weekdayView convertPoint:location fromView:self.view];
        NSIndexPath *path = [self.weekdayView indexPathForRowAtPoint:cellPostion];
        if (!path) return nil;
        WeekdayTableViewCell *cell = [self.weekdayView cellForRowAtIndexPath:path];
        if (cell.workouts.count == 0) return nil;
        wVC.workout = cell.workouts.firstObject;
        previewingContext.sourceRect = [self.view convertRect:[self.weekdayView sourceRectForIndex:path]
                                                     fromView:self.weekdayView];
    }
    else {
        CGPoint cellPostion = [self.calendarView.collectionView convertPoint:location fromView:self.view];
        //COCOAPODS FSCALENDAR FIX: Move collectionview from FSCalendar.m to FSCalendar.h
        NSIndexPath *path = [self.calendarView.collectionView indexPathForItemAtPoint:cellPostion];
        if (!path) return nil;
        NSIndexPath *lP = [self.calendarView.collectionView indexPathForCell:self.calendarView.visibleCells.firstObject];
        BTCalendarCell *cell = (BTCalendarCell *)[self.calendarView.collectionView cellForItemAtIndexPath:
                                [NSIndexPath indexPathForRow:path.row inSection:lP.section]];
        NSDate *d = [self.calendarView dateForCell:cell];
        BTWorkout *workout = [BTWorkout workoutsBetweenBeginDate:d andEndDate:[d dateByAddingTimeInterval:86400]].firstObject;
        if (!workout) return nil;
        wVC.workout = workout;
        previewingContext.sourceRect = [self.calendarView frameForDate:d];
    }
    [Log event:@"MainVC: 3D touch workout: peek" properties:@{@"Tab": @(self.segmentedControl.selectedSegmentIndex)}];
    return wVC;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [Log event:@"MainVC: 3D touch workout: pop" properties:@{@"Tab": @(self.segmentedControl.selectedSegmentIndex)}];
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)updateInterface {
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    self.blankWorkoutButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.blankWorkoutButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
    self.scanWorkoutButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    [self.scanWorkoutButton setTitleColor: [UIColor BTButtonTextSecondaryColor] forState:UIControlStateNormal];
    self.templateButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    [self.templateButton setTitleColor: [UIColor BTButtonTextSecondaryColor] forState:UIControlStateNormal];
    self.rightBarButton.tintColor = [UIColor BTTextPrimaryColor];
    [self.leftBarButton setImage:[[UIImage imageNamed:@"Chart"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                        forState:UIControlStateNormal];
    self.leftBarButton.tintColor = [UIColor BTTextPrimaryColor];
    [self updateTableViewColors];
}

- (void)updateTableViewColors {
    NSInteger count = _fetchedResultsController.fetchedObjects.count;
    self.listTableView.backgroundColor = (count > 0) ? [UIColor BTTableViewBackgroundColor] : [UIColor clearColor];
    self.listTableView.separatorColor = (count > 0) ? [UIColor BTTableViewSeparatorColor] : [UIColor clearColor];
    self.noWorkoutsView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.nWTitleLabel.textColor = [UIColor BTLightGrayColor];
    self.nWDescriptionLabel.textColor = [UIColor BTLightGrayColor];
    self.nWDescriptionImageView.image = [self.nWDescriptionImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.nWDescriptionImageView.tintColor = [UIColor BTLightGrayColor];
}

- (void)colorSchemeChange:(NSNotification *)notification  {
    [self updateInterface];
    [self.listTableView reloadData];
    [self.weekdayView removeFromSuperview];
    self.weekdayView = nil;
    [self viewDidLayoutSubviews];
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
        [self loadSearchBar];
        [self loadTableViewGradient];
        [self setUpCalendarView];
        [self.segmentedControlContainerView setNeedsLayout];
        [self.segmentedControlContainerView layoutIfNeeded];
        [self setUpSegmentedControl];
        [self setSelectedViewIndex:0];
    }
    self.rightBarButton.imageEdgeInsets = UIEdgeInsetsMake(8, self.rightBarButton.frame.size.width-24, 8, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    for (UIButton *button in @[self.scanWorkoutButton, self.blankWorkoutButton, self.templateButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor BTTableViewBackgroundColor].CGColor;
    }
    self.rightBarButton.layer.cornerRadius = 12;
    self.settings = [BTSettings sharedInstance];
    self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [Log event:@"MainVC: Presentation" properties:nil];
    if (self.firstLoad) {
        [self.weekdayView scrollToDate:[NSDate date]];
        self.firstLoad = NO;
    }
    if ([BTTutorialManager needsOnboarding]) {
        BTTutorialManager *manager = [[BTTutorialManager alloc] init];
        [Log event:@"MainVC: Onboarding: Presentation" properties:nil];
        [self presentViewController:[manager onboardingViewControllerforSize:self.view.frame.size] animated:YES completion:nil];
    }
    if (self.settings.activeWorkout) {
        [Log event:@"MainVC: Present active workout" properties:nil];
        [self presentWorkoutViewControllerWithWorkout:self.settings.activeWorkout];
    }
    [self updateBadgeView];
}

- (void)loadTableViewGradient {
    self.gradientView.userInteractionEnabled = NO;
    for (CALayer *layer in self.gradientView.layer.sublayers)
        [layer removeFromSuperlayer];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.gradientView.bounds;
    gradientLayer.startPoint = CGPointMake(0.5,0.0);
    gradientLayer.endPoint = CGPointMake(0.5,1.0);
    gradientLayer.locations = @[@.05,
                                @.70,
                                @1.0];
    if ([[UIColor BTTableViewBackgroundColor] isEqual:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]]) {
        gradientLayer.colors =    @[(id)[UIColor colorWithWhite:1 alpha:0].CGColor,
                                    (id)[[UIColor BTTableViewBackgroundColor] colorWithAlphaComponent:.5].CGColor,
                                    (id)[UIColor BTTableViewBackgroundColor].CGColor];
    }
    else {
        gradientLayer.colors =    @[(id)[UIColor clearColor].CGColor,
                                    (id)[[UIColor BTTableViewBackgroundColor] colorWithAlphaComponent:.5].CGColor,
                                    (id)[UIColor BTTableViewBackgroundColor].CGColor];
    }
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];
}

- (void)loadSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor BTPrimaryColor];
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.keyboardAppearance = [UIColor keyboardAppearance];
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
    self.listTableView.tableHeaderView = self.searchBar;
    [self.searchBar sizeToFit];
    self.searchBar.placeholder = @"Search for a workout";
    [self.listTableView reloadData];
    if (self.fetchedResultsController.fetchedObjects.count)
        [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)updateBadgeView {
    if (self.segmentedControl.selectedSegmentIndex == 0 && [BTAchievement numberOfUnreadAchievements]) {
        [self.rightBarButton showBadgeWithStyle:WBadgeStyleRedDot value:1 animationType:WBadgeAnimTypeNone];
        self.rightBarButton.badgeFrame = CGRectMake(0, 0, 12, 12);
        self.rightBarButton.badge.layer.cornerRadius = 6;
        self.rightBarButton.badgeCenterOffset = CGPointMake(-6, 8);
    }
    else [self.rightBarButton clearBadge];
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
         [self presentUserViewControllerWithForwardToAcheivements:NO];
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
    self.calendarView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.calendarView.firstWeekday = (self.settings.startWeekOnMonday) ? 2 : 1;
    self.calendarView.delegate = self;
    self.calendarView.dataSource = self;
    self.calendarView.headerHeight = 40;
    self.calendarView.scrollDirection = FSCalendarScrollDirectionVertical;
    self.calendarView.calendarWeekdayView.backgroundColor = [UIColor BTPrimaryColor];
    self.calendarView.calendarHeaderView.backgroundColor = [UIColor BTPrimaryColor];
    self.calendarView.appearance.headerTitleFont = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    self.calendarView.appearance.headerTitleColor = [UIColor BTTextPrimaryColor];
    self.calendarView.appearance.weekdayFont = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    self.calendarView.appearance.weekdayTextColor = [UIColor BTTextPrimaryColor];
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
    if ([BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:86400]].count > 0) {
        CGRect frame = [calendar frameForDate:date];
        CGPoint point = CGPointMake(frame.origin.x+frame.size.width/2.0, frame.origin.y+frame.size.height/2.0);
        [self presentWorkoutSelectionViewControllerWithOriginPoint:point date:date];
    }
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
    self.segmentedControl.titleTextAttributes         = @{NSForegroundColorAttributeName: [UIColor BTTextPrimaryColor],
                                                          NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightMedium]};
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName: [UIColor BTTextPrimaryColor],
                                                          NSFontAttributeName: [UIFont systemFontOfSize:15 weight:UIFontWeightMedium]};
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlContainerView addSubview:self.segmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [Log event:@"MainVC: Changed tab" properties:@{@"Mode": @"Segmented control",
                                                    @"Tab": @(self.segmentedControl.selectedSegmentIndex)}];
    [self.feedbackImpact impactOccurred];
    [self setSelectedViewIndex:self.segmentedControl.selectedSegmentIndex];
}

- (void)setSelectedViewIndex:(NSInteger)index {
    [self.searchBar resignFirstResponder];
    [self updateBadgeView];
    if (index == 0) {
        self.rightBarButton.alpha = 0;
        self.rightBarButton.backgroundColor = [UIColor clearColor];
        self.rightBarButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.rightBarButton.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        [self.rightBarButton setTitle:@"" forState:UIControlStateNormal];
        [self.rightBarButton setImage:[[UIImage imageNamed:@"User"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                             forState:UIControlStateNormal];
        self.listTableView.hidden = NO;
        self.blankWorkoutButton.hidden = NO;
        self.scanWorkoutButton.hidden = NO;
        self.templateButton.hidden = NO;
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
            self.calendarView.hidden = YES;
            self.weekdayContainerView.hidden = YES;
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
        self.weekdayContainerView.hidden = NO;
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
            self.listTableView.hidden = YES;
            self.calendarView.hidden = YES;
            self.blankWorkoutButton.hidden = YES;
            self.scanWorkoutButton.hidden = YES;
            self.templateButton.hidden = YES;
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
        self.calendarView.hidden = NO;
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
            self.listTableView.hidden = YES;
            self.weekdayContainerView.hidden = YES;
            self.blankWorkoutButton.hidden = YES;
            self.scanWorkoutButton.hidden = YES;
            self.templateButton.hidden = YES;
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

- (void)searchForText:(NSString *)string {
    self.searchString = string;
    NSError *error;
    NSPredicate *p;
    if (self.searchString.length) {
        p = [NSPredicate predicateWithFormat:@"summary CONTAINS %@", string];
        NSPredicate *p2;
        if (@available(iOS 11, *)) {
            if (self.settings.showSmartNames) {
                NSMutableArray *keys = @[].mutableCopy;
                for (NSString *key in self.settings.smartNicknameDict)
                    if ([self.settings.smartNicknameDict[key] containsString:string])
                        [keys addObject:key];
                p2 = [NSPredicate predicateWithFormat:@"smartName IN %@", keys];
            }
        }
        if (!p2) p2 = [NSPredicate predicateWithFormat:@"name CONTAINS %@", string];
        p = [NSCompoundPredicate orPredicateWithSubpredicates:@[p, p2]];
    }
    else p = nil;
    [self.fetchedResultsController.fetchRequest setPredicate:p];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
}

#pragma mark - searchBar delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchBar setShowsCancelButton:(searchText.length != 0) animated:YES];
    [self updateSearchResults];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:YES];
    [self updateSearchResults];
}

- (void)updateSearchResults {
    CGRect searchBarFrame = self.searchBar.frame;
    [self.listTableView scrollRectToVisible:searchBarFrame animated:NO];
    NSString *searchString = self.searchBar.text;
    [self searchForText:searchString];
    [self.listTableView reloadData];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num = _fetchedResultsController.fetchedObjects.count;
    self.noWorkoutsView.userInteractionEnabled = (num == 0);
    [self updateTableViewColors];
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
    cell.workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.delegate = self;
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

#pragma mark - MGSwipeTableCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    return [(WorkoutTableViewCell *)cell checkTemplateStatus];
}

- (void)swipeTableCell:(MGSwipeTableCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
    if (gestureIsActive && (state == MGSwipeStateExpandingLeftToRight || state == MGSwipeStateExpandingRightToLeft))
        [self.feedbackSelection selectionChanged];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    BTWorkout *workout;
    if ([cell isKindOfClass:WorkoutTableViewCell.class]) {
        workout = [(WorkoutTableViewCell *)cell workout];
    } else {
        workout = [(WeekdayTableViewCell *)cell workouts].firstObject;
    }
    if (direction == MGSwipeDirectionLeftToRight) {
        [Log event:@"MainVC: Swiped cell" properties:@{@"Action": @"Delete",
                                                       @"Index": @(self.segmentedControl.selectedSegmentIndex)}];
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Delete Workout"
                                                                        message:@"Are you sure you want to delete this workout? You will lose all of your hard work! This action cannot be undone."
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
        [Log event:@"MainVC: Swiped cell" properties:@{@"Action": @"Template",
                                                       @"Index": @(self.segmentedControl.selectedSegmentIndex)}];
        [BTToastManager presentToastForTemplate:![BTWorkoutTemplate templateExistsForWorkout:workout]];
        if ([BTWorkoutTemplate templateExistsForWorkout:workout])
             [BTWorkoutTemplate removeWorkoutFromTemplateList:workout];
        else [BTWorkoutTemplate saveWorkoutToTemplateList:workout];
    }
    return YES;
}

#pragma mark - weekdayView delegate

- (void)weekdayView:(WeekdayView *)weekdayView userSelectedDate:(NSDate *)date atPoint:(CGPoint)point {
    NSArray <BTWorkout *> *workouts = [BTWorkout workoutsBetweenBeginDate:date andEndDate:[date dateByAddingTimeInterval:60*60*24]];
    if (!workouts || workouts.count == 0) return;
    else if (workouts.count > 1) [self presentWorkoutSelectionViewControllerWithOriginPoint:point date:date];
    else [self presentWorkoutViewControllerWithWorkout:workouts.firstObject];
}

#pragma mark - QRScanner delegate

- (void)qrScannerVC:(BTQRScannerViewController *)qrVC didDismissWithScannedString:(NSString *)string {
    [Log event:@"MainVC: QR scanned" properties:@{@"Success": @(string != nil)}];
    BTWorkout *workout = [BTWorkout workoutForJSON:string];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - view handling

- (void)presentAnalyticsViewController {
    [Log event:@"MainVC: Present analytics" properties:@{@"Index": @(self.segmentedControl.selectedSegmentIndex)}];
    AnalyticsViewController *analyiticsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"a"];
    analyiticsVC.delegate = self;
    analyiticsVC.context = self.context;
    [self presentViewController:analyiticsVC withStyle:BTPresentationStyleFromLeft];
}

- (void)presentWorkoutViewControllerWithWorkout:(BTWorkout *)workout {
    [Log event:@"MainVC: Present workoutVC" properties:@{@"Workout": @(workout != nil),
                                                           @"Index": @(self.segmentedControl.selectedSegmentIndex)}];
    WorkoutViewController *workoutVC = [self.storyboard instantiateViewControllerWithIdentifier:@"w"];
    workoutVC.delegate = self;
    workoutVC.context = self.context;
    workoutVC.workout = workout;
    [self presentViewController:workoutVC withStyle:BTPresentationStyleFromBottom];
}

- (void)presentWorkoutSummaryViewControllerWithWorkout:(BTWorkout *)workout {
    WorkoutSummaryViewController *wssVC = [self.storyboard instantiateViewControllerWithIdentifier:@"wss"];
    wssVC.delegate = self;
    wssVC.context = self.context;
    wssVC.workout = workout;
    [self presentViewController:wssVC withStyle:BTPresentationStyleNone];
    [Appirater userDidSignificantEvent:YES];
}

- (void)presentWorkoutSelectionViewControllerWithOriginPoint:(CGPoint)point date:(NSDate *)date {
    WorkoutSelectionViewController *wsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ws"];
    wsVC.delegate = self;
    wsVC.context = self.context;
    wsVC.workoutManager = self.workoutManager;
    wsVC.date = date;
    wsVC.originPoint = point;
    [self presentViewController:wsVC withStyle:BTPresentationStyleNone];
}

- (void)presentQRScannerViewController {
    [Log event:@"MainVC: Present qrVC" properties:@{@"Index": @(self.segmentedControl.selectedSegmentIndex)}];
    BTQRScannerViewController *qrVC = [[NSBundle mainBundle] loadNibNamed:@"BTQRScannerViewController" owner:self options:nil].firstObject;
    qrVC.delegate = self;
    [self presentViewController:qrVC withStyle:BTPresentationStyleFromBottom];
}

- (void)presentTemplateSelectionViewController {
    [Log event:@"MainVC: Present templateVC" properties:@{@"Index": @(self.segmentedControl.selectedSegmentIndex)}];
    TemplateSelectionViewController *tsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ts"];
    tsVC.delegate = self;
    tsVC.context = self.context;
    tsVC.settings = self.settings;
    [self presentViewController:tsVC withStyle:BTPresentationStyleFromBottom];
}

- (void)presentUserViewControllerWithForwardToAcheivements:(BOOL)forward {
    [Log event:@"MainVC: Present userVC" properties:@{@"Index": @(self.segmentedControl.selectedSegmentIndex)}];
    UserViewController *userVC = [self.storyboard instantiateViewControllerWithIdentifier:@"us"];
    userVC.delegate = self;
    userVC.context = self.context;
    userVC.forwardToAcheivements = forward;
    [self presentViewController:userVC withStyle:BTPresentationStyleFromRight];
}

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {
    [self.calendarView reloadData];
    [self.weekdayView reloadData];
}

- (void)workoutViewController:(WorkoutViewController *)workoutVC didDismissWithResultWorkout:(BTWorkout *)workout {
    if (workout && workout.duration != self.settings.activeWorkoutBeforeDuration && workout == BTWorkout.lastWorkout) {
        self.blankWorkoutButton.hidden = YES;
        self.scanWorkoutButton.hidden = YES;
        self.templateButton.hidden = YES;
        [self performSelector:@selector(presentWorkoutSummaryViewControllerWithWorkout:) withObject:workout afterDelay:.2];
    }
}

#pragma mark - workoutSummaryVC delegate

- (void)workoutSummaryViewControllerWillDismiss:(WorkoutSummaryViewController *)wsVC {
    self.blankWorkoutButton.hidden = NO;
    self.scanWorkoutButton.hidden = NO;
    self.templateButton.hidden = NO;
}

- (void)workoutSummaryViewControllerDidDismissWithAcheievementShowRequest:(WorkoutSummaryViewController *)wsVC {
    [self presentUserViewControllerWithForwardToAcheivements:YES];
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

- (BOOL)isForceTouchAvailable {
    return [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
           self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext)
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    else if (self.previewingContext) {
        [self unregisterForPreviewingWithContext:self.previewingContext];
        self.previewingContext = nil;
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
