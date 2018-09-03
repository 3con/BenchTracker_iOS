//
//  ADExercisesDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADExercisesDetailViewController.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTAchievement+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"
#import "ADEDExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "ADPodiumView.h"
#import "BTAnalyticsLineChart.h"
#import "BTAnalyticsPieChart.h"
#import "HMSegmentedControl.h"
#import "BT1RMCalculator.h"
#import "AppDelegate.h"
#import "BTButton.h"
#import "BTViewMoreView.h"

#define CELL_HEIGHT 55

@interface ADExercisesDetailViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIButton *iterationButton;

@property (weak, nonatomic) IBOutlet UIView *metricSegmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *metricSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metricLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *podiumContainerView;
@property (weak, nonatomic) IBOutlet UILabel *podiumTitleLabel;
@property (nonatomic) ADPodiumView *podiumView;

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel *graphTitleLabel;
@property (nonatomic) BTAnalyticsLineChart *graphView;
@property (weak, nonatomic) IBOutlet UILabel *graphNoDataLabel;

@property (weak, nonatomic) IBOutlet BTButton *viewMoreButton;
@property (weak, nonatomic) IBOutlet UIView *viewMoreContainerView;
@property (nonatomic) BTViewMoreView *viewMoreView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMoreHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *typeSegmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *typeSegmentedControl;

@property (weak, nonatomic) IBOutlet UIView *timeSegmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *timeSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLayoutConstraint;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BTExerciseType *exerciseType;

@property (nonatomic) UIImpactFeedbackGenerator *feedbackImpact;

@end

@implementation ADExercisesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGFLOAT_MAX);
    self.iteration = nil;
    self.feedbackImpact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [Log event:@"AD: ExerciseDetailVC: Loaded" properties:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.podiumView) { //first load
        if (!self.context) self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
        [self loadExerciseType];
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"AD exercise detail fetch error: %@, %@", error, [error userInfo]);
        }
        [self.tableView reloadData];
        [self updateTableHeightConstraint];
        for (UIView *view in @[self.graphContainerView, self.tableView]) {
            view.clipsToBounds = YES;
            view.backgroundColor = [self.color colorWithAlphaComponent:.8];
        }
        self.viewMoreButton.backgroundColor = self.color;
        [self loadPodiumView];
        [self updatePodiumView];
        [self loadViewMore];
        [self updateViewMore];
        [self updateViewMoreHeight];
        [self loadSegmentedControls];
        [self setTimeSegmentedControlCollapsed:YES];
        [self loadGraphView];
        [self loadIterationButton];
        [Log event:@"AD: ExerciseDetailVC: Presentation" properties:@{@"Type": self.exerciseType.name}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [BTAchievement markAchievementComplete:ACHIEVEMENT_ANALYZE animated:YES];
}

- (void)updateTableHeightConstraint {
    BOOL collapsed = self.typeSegmentedControl.selectedSegmentIndex == 1;
    self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-(624+72+!collapsed*65),
                                                  self.fetchedResultsController.fetchedObjects.count*CELL_HEIGHT);
}

- (IBAction)iterationButtonPressed:(UIButton *)sender {
    [self presentIterationSelectionViewControllerWithOriginPoint:sender.center];
}

- (void)loadExerciseType {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"BTExerciseType" inManagedObjectContext:self.context]];
    [request setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'",self.titleString]]];
    [request setFetchBatchSize:1];
    NSError *error;
    self.exerciseType = [self.context executeFetchRequest:request error:&error].firstObject;
    if (error) NSLog(@"AD exercise detail type fetch error: %@, %@", error, [error userInfo]);
}

- (void)loadGraphView {
    BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc]
        initWithFrame:CGRectMake(5, 10, (MIN(500,self.view.frame.size.width-40))+10, 198)];
    lineChart.yAxisSpaceTop = 2;
    self.graphView = lineChart;
    [self.graphContainerView addSubview:self.graphView];
    [self updateGraphView];
}

- (IBAction)viewMoreButtonPressed:(UIButton *)sender {
    self.viewMoreView.expanded = !self.viewMoreView.expanded;
    [Log event:@"AD: ExerciseDetailVC: View more pressed" properties:@{@"Expanded": @(self.viewMoreView.expanded)}];
    [self updateViewMoreHeight];
}

- (void)loadViewMore {
    self.viewMoreView = [[NSBundle mainBundle] loadNibNamed:@"BTViewMoreView" owner:self options:nil].firstObject;
    self.viewMoreView.color = [self.color colorWithAlphaComponent:.8];
    self.viewMoreView.exerciseType = self.exerciseType;
    self.viewMoreView.iteration = self.iteration;
    self.viewMoreView.expanded = NO;
    self.viewMoreView.frame = self.viewMoreContainerView.bounds;
    self.viewMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.viewMoreContainerView addSubview:self.viewMoreView];
}

- (void)updateViewMore {
    self.viewMoreView.iteration = self.iteration;
}

- (void)updateViewMoreHeight {
    [self.viewMoreButton setTitle:(self.viewMoreView.expanded) ? @"Show Less" : @"Show More" forState:UIControlStateNormal];
    self.viewMoreHeightConstraint.constant = self.viewMoreView.preferredHeight;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        self.viewMoreView.alpha = self.viewMoreView.expanded;
    } completion:nil];
}

- (void)updateGraphView {
    __block int optMax = (self.view.frame.size.width-80)/38;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([self.exerciseType.style isEqualToString:STYLE_CUSTOM]) {
            self.graphTitleLabel.text = @"";
            self.graphNoDataLabel.text = @"No Graph Available";
            self.graphView.alpha = 0;
            return;
        }
        NSString *s = (self.typeSegmentedControl.selectedSegmentIndex == 0) ? @"Recent" :
                      (self.typeSegmentedControl.selectedSegmentIndex == 1) ? @"Top" : @"";
        if ([self.exerciseType.style isEqualToString:STYLE_REPSWEIGHT])      s = (self.metricSegmentedControl.selectedSegmentIndex == 1) ?
            [s stringByAppendingString:@" Total Volumes"] :
            [s stringByAppendingString:@" 1RM Equivalents"];
        else if ([self.exerciseType.style isEqualToString:STYLE_REPS])       s = [s stringByAppendingString:@" Max Reps"];
        else if ([self.exerciseType.style isEqualToString:STYLE_TIMEWEIGHT]) s = [s stringByAppendingString:@" Max Loads"];
        else if ([self.exerciseType.style isEqualToString:STYLE_TIME])       s = [s stringByAppendingString:@" Max Durations"];
        if (self.typeSegmentedControl.selectedSegmentIndex == 2)
            s = [[s substringFromIndex:1] stringByAppendingString:@": Rolling Average"];
        dispatch_async(dispatch_get_main_queue(), ^{ self.graphTitleLabel.text = s; });
        NSMutableArray *xAxisArr = [NSMutableArray array];
        NSMutableArray *yAxisArr = [NSMutableArray array];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMMM d";
        if (self.typeSegmentedControl.selectedSegmentIndex <= 1) {
            for (int i = 0; i < MIN(self.fetchedResultsController.fetchedObjects.count, MIN(15, optMax)); i++) {
                BTExercise *exercise = self.fetchedResultsController.fetchedObjects[i];
                [xAxisArr addObject:[formatter stringFromDate:exercise.workout.date]];
                [yAxisArr addObject:[NSNumber numberWithFloat:
                                     (self.metricSegmentedControl.selectedSegmentIndex == 1) ? exercise.volume : exercise.oneRM]];
            }
        }
        else if (self.fetchedResultsController.fetchedObjects.count >= 15) {
            int offset = self.fetchedResultsController.fetchedObjects.count % 3;
            for (int i = 0; i < self.fetchedResultsController.fetchedObjects.count/3; i++) {
                BTExercise *first = self.fetchedResultsController.fetchedObjects[3*i+offset];
                BTExercise *second = self.fetchedResultsController.fetchedObjects[3*i+1+offset];
                BTExercise *third = self.fetchedResultsController.fetchedObjects[3*i+2+offset];
                if (self.metricSegmentedControl.selectedSegmentIndex == 1)
                     [yAxisArr addObject:[NSNumber numberWithFloat:(first.volume+second.volume+third.volume)/3.0]];
                else [yAxisArr addObject:[NSNumber numberWithFloat:(first.oneRM+second.oneRM+third.oneRM)/3.0]];
                [xAxisArr addObject:(i == 0) ? [formatter stringFromDate:first.workout.date] :
                    (i == self.fetchedResultsController.fetchedObjects.count/3-1) ?
                        [formatter stringFromDate:third.workout.date] : @""];
            }
        }
        else if (self.fetchedResultsController.fetchedObjects.count >= 3) {
            int64_t first = 0;
            int64_t second = (self.metricSegmentedControl.selectedSegmentIndex == 1) ?
                                ((BTExercise *)self.fetchedResultsController.fetchedObjects[0]).volume :
                                ((BTExercise *)self.fetchedResultsController.fetchedObjects[0]).oneRM;
            int64_t third = (self.metricSegmentedControl.selectedSegmentIndex == 1) ?
                                ((BTExercise *)self.fetchedResultsController.fetchedObjects[1]).volume :
                                ((BTExercise *)self.fetchedResultsController.fetchedObjects[0]).oneRM;
            for (int i = 2; i < self.fetchedResultsController.fetchedObjects.count; i++) {
                BTExercise *exercise = self.fetchedResultsController.fetchedObjects[i];
                first = second; second = third;
                third = (self.metricSegmentedControl.selectedSegmentIndex == 1) ? exercise.volume : exercise.oneRM;
                [yAxisArr addObject:[NSNumber numberWithFloat:(first+second+third)/3.0]];
                [xAxisArr addObject:(i == 2 || i == self.fetchedResultsController.fetchedObjects.count-1) ?
                    [formatter stringFromDate:exercise.workout.date] : @""];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.graphNoDataLabel.alpha = (xAxisArr.count == 0);
            self.graphView.alpha = (xAxisArr.count != 0);
            [self.graphView setXAxisData:[[xAxisArr reverseObjectEnumerator] allObjects]];
            [self.graphView setYAxisData:[[yAxisArr reverseObjectEnumerator] allObjects]];
            [self.graphView strokeChart];
        });
    });
}

- (void)loadPodiumView {
    self.podiumContainerView.backgroundColor = [UIColor clearColor];
    self.podiumView = [[NSBundle mainBundle] loadNibNamed:@"ADPodiumView" owner:self options:nil].firstObject;
    self.podiumView.frame = CGRectMake(0, 0, self.podiumContainerView.frame.size.width,
                                             self.podiumContainerView.frame.size.height);
    self.podiumView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.podiumContainerView addSubview:self.podiumView];
    self.podiumView.color = [self.color colorWithAlphaComponent:.8];
    self.podiumTitleLabel.textColor = self.color;
}

- (void)updatePodiumView {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"BTExercise" inManagedObjectContext:self.context]];
        [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:
                                        (self.metricSegmentedControl.selectedSegmentIndex == 1) ? @"volume" : @"oneRM" ascending:NO]]];
        [request setPredicate:[self predicateForExerciseTypeIterationAndTime]];
        [request setFetchBatchSize:3];
        NSError *error;
        NSArray <BTExercise *> *topArr = [self.context executeFetchRequest:request error:&error];
        if (error) NSLog(@"AD exercise detail top fetch error: %@, %@", error, [error userInfo]);
        NSMutableArray *dateArray = [NSMutableArray array];
        NSMutableArray *valueArray = [NSMutableArray array];
        NSMutableArray *subValueArray = [NSMutableArray array];
        for (int i = 0; i < 3; i++) {
            if (topArr.count > i) {
                if ([topArr[i].style isEqualToString:STYLE_CUSTOM]) break;
                [dateArray addObject:topArr[i].workout.date];
                if ([topArr[i].style isEqualToString:STYLE_REPSWEIGHT]) {
                    if (self.metricSegmentedControl.selectedSegmentIndex == 1) {
                        [valueArray addObject:(topArr[i].volume < 10000) ?
                            [NSString stringWithFormat:@"%lld %@", topArr[i].volume, self.settings.weightSuffix] :
                            [NSString stringWithFormat:@"%.1fk %@", topArr[i].volume/1000.0, self.settings.weightSuffix]];
                    }
                    else [valueArray addObject:[NSString stringWithFormat:@"%lld %@", topArr[i].oneRM, self.settings.weightSuffix]];
                }
                else if ([topArr[i].style isEqualToString:STYLE_REPS])
                    [valueArray addObject:[NSString stringWithFormat:@"%lld reps", topArr[i].oneRM]];
                else if ([topArr[i].style isEqualToString:STYLE_TIME])
                    [valueArray addObject:[NSString stringWithFormat:@"%lld secs", topArr[i].oneRM]];
                else if ([topArr[i].style isEqualToString:STYLE_TIMEWEIGHT])
                    [valueArray addObject:[NSString stringWithFormat:@"%lld %@", topArr[i].oneRM, self.settings.weightSuffix]];
                if ([topArr[i].style isEqualToString:STYLE_REPSWEIGHT]) {
                    NSArray <NSString *> *sets = [NSKeyedUnarchiver unarchiveObjectWithData:topArr[i].sets];
                    if (self.metricSegmentedControl.selectedSegmentIndex == 1)
                        [subValueArray addObject:[NSString stringWithFormat:@"%ld sets", sets.count]];
                    else {
                        for (NSString *set in sets) {
                            NSArray <NSString *> *a = [set componentsSeparatedByString:@" "];
                            if ([BT1RMCalculator equivilentForReps:a[0].intValue weight:a[1].floatValue] == topArr[i].oneRM) {
                                [subValueArray addObject:[set stringByReplacingOccurrencesOfString:@" " withString:@" x "]];
                                break;
                            }
                        }
                    }
                }
                else [subValueArray addObject:@""];
            }
        }
        self.podiumView.dates = dateArray;
        self.podiumView.values = valueArray;
        self.podiumView.subValues = subValueArray;
        [self.podiumView animateIn];
    });
}

- (void)loadIterationButton {
    self.iterationButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.iterationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self updateIterationButtonText];
}

- (void)updateIterationButtonText {
    if ([[NSKeyedUnarchiver unarchiveObjectWithData:self.exerciseType.iterations] count] == 0) {
        NSString *buttonText = [NSString stringWithFormat:@"%@\nNo Variations",self.exerciseType.name];
        NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:buttonText];
        [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightBold],
                             NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.8]}
                     range:NSMakeRange(mAS.length-13, 13)];
        [self.iterationButton setAttributedTitle:mAS forState:UIControlStateNormal];
        self.iterationButton.enabled = NO;
    }
    else {
        NSString *buttonText = (self.iteration.length > 0) ?
            [NSString stringWithFormat:@"%@ %@\nTap to Change Variation", self.iteration, self.titleString] :
            [NSString stringWithFormat:@"%@\nTap to Select a Variation", self.titleString];
        int length = (self.iteration.length > 0) ? 23 : 25;
        NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:buttonText];
        [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightBold],
                             NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.8]}
                     range:NSMakeRange(mAS.length-length, length)];
        [self.iterationButton setAttributedTitle:mAS forState:UIControlStateNormal];
    }
}

#pragma mark - segmedtedControl

- (void)loadSegmentedControls {
    self.metricSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"One-Rep Max", @"Volume"]];
    self.typeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Recent", @"Top", @"Average"]];
    self.timeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"All-Time", @"30-Day"]];
    for (HMSegmentedControl *segmentedControl in @[self.metricSegmentedControl, self.timeSegmentedControl, self.typeSegmentedControl]) {
        segmentedControl.frame = CGRectMake(0, 0, self.timeSegmentedControlContainerView.frame.size.width,
                                            self.timeSegmentedControlContainerView.frame.size.height);
        segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        segmentedControl.layer.cornerRadius = 16;
        segmentedControl.clipsToBounds = YES;
        segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
        segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
        segmentedControl.backgroundColor = self.color;
        segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
        segmentedControl.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                [UIColor whiteColor], NSForegroundColorAttributeName,
                                                [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
        segmentedControl.selectedTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                                        [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
        [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    }
    BOOL showMetrics = [self.exerciseType.style isEqualToString:STYLE_REPSWEIGHT];
    if (showMetrics) [self.metricSegmentedControlContainerView addSubview:self.metricSegmentedControl];
    self.metricLayoutConstraint.active = !showMetrics;
    [self.timeSegmentedControlContainerView addSubview:self.timeSegmentedControl];
    [self.typeSegmentedControlContainerView addSubview:self.typeSegmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self.feedbackImpact impactOccurred];
    [self setTimeSegmentedControlCollapsed:self.typeSegmentedControl.selectedSegmentIndex != 1];
    [self updateFetchRequest:self.fetchedResultsController.fetchRequest];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
    [self updateGraphView];
    [self updateTableHeightConstraint];
    if (segmentedControl == self.metricSegmentedControl) {
        [self updatePodiumView];
    }
}

- (void)setTimeSegmentedControlCollapsed:(BOOL)collapsed {
    self.timeSegmentedControlContainerView.userInteractionEnabled = !collapsed;
    self.timeLayoutConstraint.constant = (collapsed) ? 20 : 90;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
        self.timeSegmentedControlContainerView.alpha = !collapsed;
    } completion:nil];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTExercise"];
    [self updateFetchRequest:fetchRequest];
    fetchRequest.fetchLimit = 100;
    fetchRequest.fetchBatchSize = 5;
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)updateFetchRequest:(NSFetchRequest *)request {
    [Log event:@"AD: ExerciseDetailVC: Changed metric"
    properties:@{@"Metric": (self.metricSegmentedControl.selectedSegmentIndex == 1) ? @"Volume" : @"1RM"}];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"workout.date" ascending:NO]];
    if (self.typeSegmentedControl.selectedSegmentIndex == 1) {
        NSSortDescriptor *d = (self.metricSegmentedControl.selectedSegmentIndex == 1) ?
                                    [NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:NO] :
                                    [NSSortDescriptor sortDescriptorWithKey:@"oneRM" ascending:NO];
        request.sortDescriptors = @[d, request.sortDescriptors.firstObject];
    }
    [request setPredicate:[self predicateForExerciseTypeIterationAndTime]];
}

- (NSPredicate *)predicateForExerciseTypeIterationAndTime {
    NSPredicate *p3;
    if (self.typeSegmentedControl.selectedSegmentIndex == 1 && self.timeSegmentedControl.selectedSegmentIndex == 1)
        p3 = [NSPredicate predicateWithFormat:@"workout.date >= %@", [NSDate.date dateByAddingTimeInterval:-86400*30]];
    NSPredicate *p1 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'", self.titleString]];
    NSPredicate *p2 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"iteration == '%@'", self.iteration]];
    NSPredicate *p4 = (p3) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p3]] : p1;
    return (self.iteration.length > 0) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[p4, p2]] : p4;
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

- (void)configureExerciseCell:(ADEDExerciseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExercise *exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.color = self.color;
    cell.isVolume = self.metricSegmentedControl.selectedSegmentIndex == 1;
    [cell loadExercise:exercise withWeightSuffix:[self.settings weightSuffix]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADEDExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) cell = [[NSBundle mainBundle] loadNibNamed:@"ADEDExerciseTableViewCell" owner:self options:nil].firstObject;
    [self configureExerciseCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTExercise *exercise = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self presentWorkoutViewControllerWithWorkout:exercise.workout];
}

#pragma mrk - iterationVC delegate

- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration {
    [Log event:@"AD: ExerciseDetailVC: Change iteration" properties:@{@"Iteration": (iteration) ? iteration : @"None"}];
    [self.typeSegmentedControl setSelectedSegmentIndex:0 animated:YES];
    self.iteration = iteration;
    [self updateIterationButtonText];
    [self updatePodiumView];
    NSError *error;
    [self updateFetchRequest:self.fetchedResultsController.fetchRequest];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"AD exercise detail fetch error: %@, %@", error, [error userInfo]);
    }
    [self updateGraphView];
    [self updateViewMore];
    [self.tableView reloadData];
    self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-624-72,
                                                  self.fetchedResultsController.fetchedObjects.count*CELL_HEIGHT);
}

- (void)iterationSelectionVCDidDismiss:(IterationSelectionViewController *)iterationVC {
    
}

#pragma mark - view handling

- (void)presentIterationSelectionViewControllerWithOriginPoint:(CGPoint)point {
    IterationSelectionViewController *isVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
                                                      instantiateViewControllerWithIdentifier:@"is"];
    isVC.delegate = self;
    isVC.exerciseType = self.exerciseType;
    isVC.originPoint = point;
    isVC.color = self.color;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:isVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    isVC.transitioningDelegate = self.animator;
    isVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:isVC animated:YES completion:nil];
}

- (void)presentWorkoutViewControllerWithWorkout:(BTWorkout *)workout {
    [Log event:@"AD: ExerciseDetailVC: Workout pressed" properties:nil];
    WorkoutViewController *workoutVC = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]]
                                        instantiateViewControllerWithIdentifier:@"w"];
    workoutVC.delegate = self;
    workoutVC.context = self.context;
    workoutVC.workout = workout;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:workoutVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    workoutVC.transitioningDelegate = self.animator;
    workoutVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:workoutVC animated:YES completion:nil];
}

#pragma mark - workoutVC delegate

- (void)workoutViewController:(WorkoutViewController *)workoutVC willDismissWithResultWorkout:(BTWorkout *)workout {

}

- (void)workoutViewController:(WorkoutViewController *)workoutVC didDismissWithResultWorkout:(BTWorkout *)workout {
    
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
            [self configureExerciseCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate: break;
        case NSFetchedResultsChangeMove: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
    self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-624-72,
                                                  self.fetchedResultsController.fetchedObjects.count*CELL_HEIGHT);
}

@end
