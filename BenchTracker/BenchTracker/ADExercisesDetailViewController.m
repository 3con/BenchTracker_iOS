//
//  ADExercisesDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADExercisesDetailViewController.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"
#import "ADEDExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"
#import "ADPodiumView.h"
#import "BTAnalyticsLineChart.h"
#import "HMSegmentedControl.h"
#import "BT1RMCalculator.h"

#define CELL_HEIGHT 55

@interface ADExercisesDetailViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIButton *iterationButton;

@property (weak, nonatomic) IBOutlet UIView *podiumContainerView;
@property (weak, nonatomic) IBOutlet UILabel *podiumTitleLabel;
@property (nonatomic) ADPodiumView *podiumView;

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel *graphTitleLabel;
@property (nonatomic) BTAnalyticsLineChart *graphView;
@property (weak, nonatomic) IBOutlet UILabel *graphNoDataLabel;

@property (weak, nonatomic) IBOutlet UIView *segmentedControllerContainerView;
@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BTExerciseType *exerciseType;
@property (nonatomic) NSString *iteration;

@end

@implementation ADExercisesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGFLOAT_MAX);
    self.iteration = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadExerciseType];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"AD exercise detail fetch error: %@, %@", error, [error userInfo]);
    }
    self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-624-72,
                                                  self.fetchedResultsController.fetchedObjects.count*CELL_HEIGHT);
    if (!self.podiumView) {
        for (UIView *view in @[self.iterationButton, self.podiumContainerView, self.graphContainerView, self.tableView]) {
            view.layer.cornerRadius = 12;
            view.clipsToBounds = YES;
            view.backgroundColor = [self.color colorWithAlphaComponent:.8];
        }
        [self loadPodiumView];
        [self loadSegmentedControl];
        [self loadGraphView];
        [self loadIterationButton];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.podiumView.hasAnimatedIn)
        [self.podiumView animateIn];
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
    if ([self.exerciseType.style isEqualToString:STYLE_REPSWEIGHT])      self.graphTitleLabel.text = @"Recent 1RM Equivilents";
    else if ([self.exerciseType.style isEqualToString:STYLE_REPS])       self.graphTitleLabel.text = @"Recent Max Reps";
    else if ([self.exerciseType.style isEqualToString:STYLE_TIMEWEIGHT]) self.graphTitleLabel.text = @"Recent Max Loads";
    else if ([self.exerciseType.style isEqualToString:STYLE_TIME])       self.graphTitleLabel.text = @"Recent Max Durations";
    else {
        self.graphTitleLabel.text = @"";
        self.graphNoDataLabel.text = @"No Graph Available";
    }
    BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc]
        initWithFrame:CGRectMake(5, 10, (MIN(500,self.view.frame.size.width-40))+10, 198)];
    lineChart.yAxisSpaceTop = 2;
    self.graphView = lineChart;
    [self.graphContainerView addSubview:self.graphView];
    [self updateGraphView];
}

- (void)updateGraphView {
    if ([self.exerciseType.style isEqualToString:STYLE_CUSTOM]) {
        self.graphView.alpha = 0;
        return;
    }
    NSMutableArray *xAxisArr = [NSMutableArray array];
    NSMutableArray *yAxisArr = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMMM d";
    for (BTExercise *exercise in self.fetchedResultsController.fetchedObjects) {
        [xAxisArr addObject:[formatter stringFromDate:exercise.workout.date]];
        [yAxisArr addObject:[NSNumber numberWithFloat:exercise.oneRM]];
    }
    self.graphNoDataLabel.alpha = (xAxisArr.count == 0);
    [self.graphView setXAxisData:[[xAxisArr reverseObjectEnumerator] allObjects]];
    [self.graphView setYAxisData:[[yAxisArr reverseObjectEnumerator] allObjects]];
    [self.graphView strokeChart];
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
    [self updatePodiumView];
}

- (void)updatePodiumView {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"BTExercise" inManagedObjectContext:self.context]];
    [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"oneRM" ascending:NO]]];
    [request setPredicate:[self predicateForExerciseTypeAndIteration]];
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
            if ([topArr[i].style isEqualToString:STYLE_REPSWEIGHT])
                [valueArray addObject:[NSString stringWithFormat:@"%lld %@", topArr[i].oneRM, self.settings.weightSuffix]];
            else if ([topArr[i].style isEqualToString:STYLE_REPS])
                [valueArray addObject:[NSString stringWithFormat:@"%lld reps", topArr[i].oneRM]];
            else if ([topArr[i].style isEqualToString:STYLE_TIME])
                [valueArray addObject:[NSString stringWithFormat:@"%lld secs", topArr[i].oneRM]];
            else if ([topArr[i].style isEqualToString:STYLE_TIMEWEIGHT])
                [valueArray addObject:[NSString stringWithFormat:@"%lld %@", topArr[i].oneRM, self.settings.weightSuffix]];
            if ([topArr[i].style isEqualToString:STYLE_REPSWEIGHT]) {
                for (NSString *set in [NSKeyedUnarchiver unarchiveObjectWithData:topArr[i].sets]) {
                    NSArray <NSString *> *a = [set componentsSeparatedByString:@" "];
                    if ([BT1RMCalculator equivilentForReps:a[0].intValue weight:a[1].floatValue] == topArr[i].oneRM) {
                        [subValueArray addObject:[set stringByReplacingOccurrencesOfString:@" " withString:@" x "]];
                        break;
                    }
                }
            }
            else [subValueArray addObject:@""];
        }
    }
    self.podiumView.dates = dateArray;
    self.podiumView.values = valueArray;
    self.podiumView.subValues = subValueArray;
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
            [NSString stringWithFormat:@"Variation: %@ %@\nTap to Change", self.iteration, self.titleString] :
            [NSString stringWithFormat:@"%@: All Variations\nTap to Change", self.titleString];
        NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:buttonText];
        [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightBold],
                             NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.8]}
                     range:NSMakeRange(mAS.length-13, 13)];
        [self.iterationButton setAttributedTitle:mAS forState:UIControlStateNormal];
    }
}

#pragma mark - segmedtedControl

- (void)loadSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Recent", @"Top"]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.segmentedControllerContainerView.frame.size.width,
                                                   self.segmentedControllerContainerView.frame.size.height);
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.segmentedControl.layer.cornerRadius = 12;
    self.segmentedControl.clipsToBounds = YES;
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleBox;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedControl.backgroundColor = self.color;
    self.segmentedControl.selectionIndicatorBoxColor = [UIColor whiteColor];
    self.segmentedControl.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [UIColor whiteColor], NSForegroundColorAttributeName,
                                                 [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
    self.segmentedControl.selectedTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                                         [UIFont systemFontOfSize:15 weight:UIFontWeightMedium], NSFontAttributeName, nil];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControllerContainerView addSubview:self.segmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self updateFetchRequest:self.fetchedResultsController.fetchRequest];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"BTExercise" inManagedObjectContext:self.context]];
    [self updateFetchRequest:fetchRequest];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)updateFetchRequest:(NSFetchRequest *)request {
    if (self.segmentedControl.selectedSegmentIndex == 0)
         [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"workout.date" ascending:NO]]];
    else if (self.segmentedControl.selectedSegmentIndex == 1)
         [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"oneRM" ascending:NO]]];
    else [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"oneRM" ascending:NO]]];
    [request setPredicate:[self predicateForExerciseTypeAndIteration]];
}

- (NSPredicate *)predicateForExerciseTypeAndIteration {
    NSPredicate *p1 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'",self.titleString]];
    NSPredicate *p2;
    if (self.iteration.length > 0) p2 = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"iteration == '%@'",self.iteration]];
    return (p2) ? [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]] : p1;
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
    [cell loadExercise:exercise withWeightSuffix:[self.settings weightSuffix]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADEDExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"ADEDExerciseTableViewCell" owner:self options:nil].firstObject;
    }
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
    [self.segmentedControl setSelectedSegmentIndex:0 animated:YES];
    self.iteration = iteration;
    [self updateIterationButtonText];
    [self updatePodiumView];
    [self.podiumView animateIn];
    NSError *error;
    [self updateFetchRequest:self.fetchedResultsController.fetchRequest];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"AD exercise detail fetch error: %@, %@", error, [error userInfo]);
    }
    [self updateGraphView];
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
