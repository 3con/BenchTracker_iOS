//
//  ADExercisesDetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADExercisesDetailViewController.h"
#import "BTExercise+CoreDataClass.h"
#import "ADPodiumView.h"
#import "BTAnalyticsLineChart.h"
#import "HMSegmentedControl.h"

@interface ADExercisesDetailViewController ()

@property (weak, nonatomic) IBOutlet UIButton *iterationButton;

@property (weak, nonatomic) IBOutlet UIView *podiumContainerView;
@property (weak, nonatomic) IBOutlet UILabel *podiumTitleLabel;
@property (nonatomic) ADPodiumView *podiumView;

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel *graphTitleLabel;
@property (nonatomic) BTAnalyticsLineChart *graphView;

@property (weak, nonatomic) IBOutlet UIView *segmentedControllerContainerView;
@property (nonatomic) HMSegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ADExercisesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.scrollEnabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    self.tableViewHeightConstraint.constant = MAX(120, self.fetchedResultsController.fetchedObjects.count*40);
    for (UIView *view in @[self.iterationButton, self.podiumContainerView, self.graphContainerView, self.tableView]) {
        view.layer.cornerRadius = 12;
        view.clipsToBounds = YES;
        view.backgroundColor = [self.color colorWithAlphaComponent:.8];
    }
    [self loadPodiumView];
    [self loadGraph];
    [self loadIterationButton];
}

- (void)loadGraph {
    BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc]
                                       initWithFrame:CGRectMake(5, 10, self.graphContainerView.frame.size.width+10, 198)];
    [lineChart setXAxisData:@[@"J 30", @"J 30", @"J 30", @"J 30", @"J 30", @"J 30", @"J 30", @"J 30", @"J 30", @"J 30"]];
    [lineChart setYAxisData:@[@200, @205, @202, @215, @218, @210, @212, @205, @220, @223]];
    self.graphView = lineChart;
    [self.graphContainerView addSubview:self.graphView];
    [self.graphView strokeChart];
    self.graphTitleLabel.text = [NSString stringWithFormat:@"Last %ld %@",self.graphView.xLabels.count,@"1RM Equivilents"];
}

- (void)loadPodiumView {
    self.podiumContainerView.backgroundColor = [UIColor clearColor];
    [self setUpSegmentedControl];
    self.podiumView = [[NSBundle mainBundle] loadNibNamed:@"ADPodiumView" owner:self options:nil].firstObject;
    self.podiumView.frame = CGRectMake(0, 0, self.podiumContainerView.frame.size.width,
                                       self.podiumContainerView.frame.size.height);
    [self.podiumContainerView addSubview:self.podiumView];
    self.podiumView.color = [self.color colorWithAlphaComponent:.8];
    self.podiumTitleLabel.textColor = self.color;
    NSMutableArray *dateArray = [NSMutableArray array];
    NSMutableArray *valueArray = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        //        NSArray *a = [self dateAndValueForIndex:i];
        //        [dateArray addObject:a[0]];
        //        [valueArray addObject:a[1]];
    }
    self.podiumView.dates = dateArray;
    self.podiumView.values = valueArray;
}

- (void)loadIterationButton {
    self.iterationButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.iterationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *mAS = [[NSMutableAttributedString alloc] initWithString:
                                      [NSString stringWithFormat:@"%@: All Variations\nTap to Change", self.titleString]];
    [mAS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightBold],
                         NSForegroundColorAttributeName: [UIColor colorWithWhite:1 alpha:.8]}
                 range:NSMakeRange(mAS.length-13, 13)];
    [self.iterationButton setAttributedTitle:mAS forState:UIControlStateNormal];
}

#pragma mark - segmedtedControl

- (void)setUpSegmentedControl {
    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Recent", @"Top", @"1RM Only"]];
    self.segmentedControl.frame = CGRectMake(0, 0, self.segmentedControllerContainerView.frame.size.width,
                                             self.segmentedControllerContainerView.frame.size.height);
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
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name == '%@'",self.titleString]]];
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
    if (self.segmentedControl.selectedSegmentIndex == 0)
         [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"workout.date" ascending:NO]]];
    else if (self.segmentedControl.selectedSegmentIndex == 1)
         [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"oneRM" ascending:NO]]];
    else [request setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"oneRM" ascending:NO]]];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)configureWorkoutCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExercise *exercise = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",exercise.name,exercise.sets];
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

@end
