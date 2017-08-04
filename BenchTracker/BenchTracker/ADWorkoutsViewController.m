//
//  ADWorkoutsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADWorkoutsViewController.h"
#import "ADPodiumView.h"
#import "HMSegmentedControl.h"
#import "BTWorkout+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

#define QUERY_TYPE_VOLUME       0
#define QUERY_TYPE_DURATION     1
#define QUERY_TYPE_NUMEXERCISES 2
#define QUERY_TYPE_NUMSETS      3

@interface ADWorkoutsViewController ()

@property (weak, nonatomic) IBOutlet UIView *podiumContainerView;
@property (weak, nonatomic) IBOutlet UILabel *podiumTitleLabel;
@property (nonatomic) ADPodiumView *podiumView;

@property (weak, nonatomic) IBOutlet UIView *segmentedControlContainerView;
@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) NSInteger queryType;

@end

@implementation ADWorkoutsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [BTSettings sharedInstance];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.layer.cornerRadius = 12;
    self.tableView.clipsToBounds = YES;
    self.tableView.scrollEnabled = NO;
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
        self.tableView.backgroundColor = [self.color colorWithAlphaComponent:.8];
        [self setUpSegmentedControl];
        [self loadPodiumView];
        self.tableViewHeightConstraint.constant = MAX(self.view.frame.size.height-(314+72), self.fetchedResultsController.fetchedObjects.count*40);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.podiumView animateIn];
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
        NSArray *a = [self dateAndValueForIndex:i];
        [dateArray addObject:a[0]];
        [valueArray addObject:a[1]];
    }
    self.podiumView.dates = dateArray;
    self.podiumView.values = valueArray;
    self.podiumView.subValues = @[];
}

#pragma mark - segmedtedControl

- (void)setUpSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Top", @"Recent"]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.segmentedControlContainerView.frame.size.width,
                                                   self.segmentedControlContainerView.frame.size.height);
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
    [self.segmentedControlContainerView addSubview:self.segmentedControl];
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
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"BTWorkout" inManagedObjectContext:self.context]];
    [self updateFetchRequest:fetchRequest];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
                                                               initWithFetchRequest:fetchRequest managedObjectContext:self.context
                                                               sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)updateFetchRequest:(NSFetchRequest *)request {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        if (self.queryType == QUERY_TYPE_VOLUME)
             [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"volume" ascending:NO]]];
        else if (self.queryType == QUERY_TYPE_DURATION)
             [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"duration" ascending:NO]]];
        else if (self.queryType == QUERY_TYPE_NUMEXERCISES)
             [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"numExercises" ascending:NO]]];
        else [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"numSets" ascending:NO]]];
    }
    else     [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)configureWorkoutCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSArray *a = [self dateAndValueForIndex:indexPath.row];
    cell.textLabel.attributedText = [self attributedStringForDate:a[0] value:a[1]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    [self configureWorkoutCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - helper methods

- (NSArray *)dateAndValueForIndex:(NSInteger)index {
    BTWorkout *workout = self.fetchedResultsController.fetchedObjects[index];
    NSString *suffix = (self.queryType == QUERY_TYPE_VOLUME) ? [NSString stringWithFormat:@"k %@", self.settings.weightSuffix] :
                       (self.queryType == QUERY_TYPE_DURATION) ? @" min" : @"";
    long value = (self.queryType == QUERY_TYPE_VOLUME) ? workout.volume/1000 :
                 (self.queryType == QUERY_TYPE_DURATION) ? workout.duration/60 :
                 (self.queryType == QUERY_TYPE_NUMEXERCISES) ? workout.numExercises : workout.numSets;
    return @[workout.date, [NSString stringWithFormat:@"%ld%@",value,suffix]];
}

- (NSAttributedString *)attributedStringForDate:(NSDate *)date value:(NSString *)value {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E, MMM d";
    NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:
                                      [NSString stringWithFormat:@"%@ %@", value, [formatter stringFromDate:date]]];
    [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy]} range:NSMakeRange(0, value.length)];
    return mAS;
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
