//
//  ADWorkoutsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADWorkoutsViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "ADPodiumView.h"
#import "HMSegmentedControl.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "ADWorkoutsTableViewCell.h"

@interface ADWorkoutsViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (weak, nonatomic) IBOutlet UIView *podiumContainerView;
@property (weak, nonatomic) IBOutlet UILabel *podiumTitleLabel;
@property (nonatomic) ADPodiumView *podiumView;

@property (weak, nonatomic) IBOutlet UIView *timeSegmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *timeSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIView *typeSegmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *typeSegmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) NSInteger queryType;

@end

@implementation ADWorkoutsViewController

@synthesize settings;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [BTSettings sharedInstance];
    self.view.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGFLOAT_MAX);
    self.tableView.contentInset = UIEdgeInsetsMake(4, 0, 4, 0);
    self.tableView.layer.cornerRadius = 16;
    self.tableView.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.podiumView) { //first load
        self.queryType = ([self.titleString containsString:@"ume"]) ? 0 :
                         ([self.titleString containsString:@"ura"]) ? 1 :
                         ([self.titleString containsString:@"xer"]) ? 2 : 3;
        if (self.queryType == QUERY_TYPE_VOLUME)            self.titleString = @"Exercise Volume";
        else if (self.queryType == QUERY_TYPE_DURATION)     self.titleString = @"Exercise Duration";
        else if (self.queryType == QUERY_TYPE_NUMEXERCISES) self.titleString = @"Number of Exercises";
        else                                                self.titleString = @"Number of Sets";
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
        }
        [self updateTableHeightConstraint];
        self.tableView.backgroundColor = [self.color colorWithAlphaComponent:.8];
        [self loadSegmentedControls];
        [self setTimeSegmentedControlCollapsed:NO];
        [self loadPodiumView];
        [Log event:@"AD: WorkoutsVC: Presentation" properties:@{@"Type": self.titleString}];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.podiumView.hasAnimatedIn)
        [self.podiumView animateIn];
}

- (void)updateTableHeightConstraint {
    BOOL collapsed = self.typeSegmentedControl.selectedSegmentIndex == 1;
    self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-(379+72+collapsed*-65),
                                                  self.fetchedResultsController.fetchedObjects.count*46+8);
}

- (void)loadPodiumView {
    self.podiumView = [[NSBundle mainBundle] loadNibNamed:@"ADPodiumView" owner:self options:nil].firstObject;
    self.podiumView.frame = CGRectMake(0, 0, self.podiumContainerView.frame.size.width,
                                             self.podiumContainerView.frame.size.height);
    self.podiumView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.podiumContainerView addSubview:self.podiumView];
    self.podiumView.color = [self.color colorWithAlphaComponent:.8];
    self.podiumTitleLabel.textColor = self.color;
    NSMutableArray *dateArray = [NSMutableArray array];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (int i = 0; i < MIN(self.fetchedResultsController.fetchedObjects.count, 3); i++) {
        BTWorkout *workout = self.fetchedResultsController.fetchedObjects[i];
        NSString *suffix = (self.queryType == QUERY_TYPE_VOLUME) ?
                                [NSString stringWithFormat:@"k %@",  self.settings.weightSuffix] :
                           (self.queryType == QUERY_TYPE_DURATION) ? @" min" : @"";
        long long value = (self.queryType == QUERY_TYPE_VOLUME) ? workout.volume/1000 :
                          (self.queryType == QUERY_TYPE_DURATION) ? workout.duration/60 :
                          (self.queryType == QUERY_TYPE_NUMEXERCISES) ? workout.numExercises : workout.numSets;
        [dateArray addObject:workout.date];
        [valueArray addObject:[NSString stringWithFormat:@"%lld%@",value,suffix]];
    }
    self.podiumView.dates = dateArray;
    self.podiumView.values = valueArray;
    self.podiumView.subValues = @[];
}

#pragma mark - segmedtedControl

- (void)loadSegmentedControls {
    self.timeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"All-Time", @"30-Day"]];
    self.typeSegmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Top", @"Recent"]];
    for (HMSegmentedControl *segmentedControl in @[self.timeSegmentedControl, self.typeSegmentedControl]) {
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
    [self.timeSegmentedControlContainerView addSubview:self.timeSegmentedControl];
    [self.typeSegmentedControlContainerView addSubview:self.typeSegmentedControl];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    [self setTimeSegmentedControlCollapsed:self.typeSegmentedControl.selectedSegmentIndex == 1];
    [self updateFetchRequest:self.fetchedResultsController.fetchRequest];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error])
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    [self.tableView reloadData];
    [self updateTableHeightConstraint];
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
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTWorkout"];
    [self updateFetchRequest:fetchRequest];
    fetchRequest.fetchBatchSize = 5;
    fetchRequest.fetchLimit = 50;
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                               managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)updateFetchRequest:(NSFetchRequest *)request {
    if (self.typeSegmentedControl.selectedSegmentIndex == 0 && self.timeSegmentedControl.selectedSegmentIndex == 1)
         request.predicate = [NSPredicate predicateWithFormat:@"date >= %@",[NSDate.date dateByAddingTimeInterval:86400*-30]];
    else request.predicate = nil;
    if (self.typeSegmentedControl.selectedSegmentIndex == 0) {
        if (self.queryType == QUERY_TYPE_VOLUME)
             request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"volume" ascending:NO]];
        else if (self.queryType == QUERY_TYPE_DURATION)
             request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"duration" ascending:NO]];
        else if (self.queryType == QUERY_TYPE_NUMEXERCISES)
             request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numExercises" ascending:NO]];
        else request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"numSets" ascending:NO]];
    }
    else     request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _fetchedResultsController.sections[section].numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)configureWorkoutCell:(ADWorkoutsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.type = self.queryType;
    cell.weightSuffix = self.settings.weightSuffix;
    cell.workout = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell layoutIfNeeded];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell layoutIfNeeded];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ADWorkoutsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"ADWorkoutsTableViewCell" owner:self
                                                        options:nil].firstObject;
    [self configureWorkoutCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [Log event:@"AD: WorkoutsVC: Workout pressed" properties:nil];
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self presentWorkoutViewControllerWithWorkout:workout];
}

#pragma mark - view handling

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
}

@end
