//
//  WorkoutSelectionViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/3/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutSelectionViewController.h"
#import "WorkoutTableViewCell.h"
#import "BTSettings+CoreDataClass.h"

@interface WorkoutSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containingView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSLayoutConstraint *tableHeightConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) BTSettings *settings;

@property (nonatomic) BOOL needsAnimation;
@property (nonatomic) BOOL firstLoad;

@end

@implementation WorkoutSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needsAnimation = YES;
    self.firstLoad = YES;
    self.scrollView.delegate = self;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    [self.view addConstraint:self.tableHeightConstraint];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ACell"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WorkoutTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    self.settings = [BTSettings sharedInstance];
}

- (void)viewDidLayoutSubviews {
    if (self.firstLoad) {
        self.tableView.layer.cornerRadius = 12.0;
        self.tableView.clipsToBounds = YES;
        //if (self.date) [self loadDate];
        self.containingView.alpha = 0.0;
        self.backgroundView.alpha = 0.0;
        self.firstLoad = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
    self.needsAnimation = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

- (IBAction)tapGesture2:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

- (IBAction)tapGesture3:(UITapGestureRecognizer *)sender {
    [self animateOut];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"BTWorkout" inManagedObjectContext:self.context]];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO]]];
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(date >= %@) AND (date < %@)", self.date,
                                                                                                 [self.date dateByAddingTimeInterval:86400]]];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
                                                               initWithFetchRequest:fetchRequest managedObjectContext:self.context
                                                               sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MAX(2, _fetchedResultsController.sections[0].numberOfObjects+1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 45;
    if (_fetchedResultsController.sections[0].numberOfObjects == 0) return 120;
    return 60;
}

- (void)configureWorkoutCell:(WorkoutTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
    if (self.settings.exerciseTypeColors)
        cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    cell.delegate = self;
    [cell loadWorkout:workout];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor BTPrimaryColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM d, y";
        label.text = [NSString stringWithFormat:@"Workouts on %@",[formatter stringFromDate:self.date]];
        [cell addSubview:label];
        return cell;
    }
    if (_fetchedResultsController.sections[0].numberOfObjects == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BCell"];
        cell.backgroundColor = [UIColor whiteColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 120)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = [UIColor BTLightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:24 weight:UIFontWeightBold];
        label.text = [NSString stringWithFormat:@"No Workouts"];
        [cell addSubview:label];
        return cell;
    }
    WorkoutTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureWorkoutCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_fetchedResultsController.sections[0].numberOfObjects == 0 || indexPath.row == 0) return;
    BTWorkout *workout = [_fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate workoutSelectionVC:self didDismissWithSelectedWorkout:workout];
    }];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
}

#pragma mark - SWTableViewCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.context deleteObject:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]]];
    [self.context save:nil];
    return YES;
}

#pragma mark - scrollView delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    bool neglegable = fabs(velocity.y) < 0.2;
    float offset = fabs(scrollView.contentOffset.y);
    bool offsetPositive = scrollView.contentOffset.y >= 0;
    bool velocityPositive = velocity.y >= 0;
    if (neglegable && offset < 60.0) { } //no dismiss
    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
    else { //dismiss
        [self animateOut];
        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (scrollView.contentOffset.y >= 0)
                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - animation

- (void)animateIn {
    self.containingView.alpha = 1.0;
    if (self.needsAnimation) {
        self.backgroundView.alpha = 0.0;
        self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
        self.tableView.alpha = 0.5;
    }
    CGPoint endPoint = self.tableView.center;
    self.tableView.center = CGPointMake(-self.containingView.frame.origin.x+self.originPoint.x,
                                          -self.containingView.frame.origin.y+self.originPoint.y);
    [UIView animateWithDuration:(self.needsAnimation)? 0.25 : 0.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.transform = CGAffineTransformIdentity;
        self.tableView.center = endPoint;
        self.tableView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:newIndexPath.row+1 inSection:newIndexPath.section];
    NSIndexPath *path = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
            if (controller.sections[0].objects.count == 0)
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureWorkoutCell:[tableView cellForRowAtIndexPath:path] atIndexPath:path];
            break;
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] withRowAnimation:UITableViewRowAnimationFade];
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
    [self.view removeConstraint:self.tableHeightConstraint];
    [self.view addConstraint:self.tableHeightConstraint];
}

- (NSLayoutConstraint *)tableHeightConstraint {
    if (!_tableHeightConstraint) {
        _tableHeightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:0];
    }
    _tableHeightConstraint.constant = (self.fetchedResultsController.sections[0].numberOfObjects == 0) ?
        45+120 : 45+60*self.fetchedResultsController.sections[0].numberOfObjects;
    return _tableHeightConstraint;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
