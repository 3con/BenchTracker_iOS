//
//  AddExerciseViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AddExerciseViewController.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "AddExerciseTableViewCell.h"
#import "ZFModalTransitionAnimator.h"

@interface AddExerciseViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (nonatomic) NSMutableDictionary <NSIndexPath *, NSString *> *selectedIterations;

@property (nonatomic) BOOL supersettingEnabled;

@property (nonatomic) NSString *searchString;

@end

@implementation AddExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIterations = [[NSMutableDictionary alloc] init];
    NSError *error;
    self.searchString = @"";
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTSettings"];
    BTSettings *settings = [self.context executeFetchRequest:fetchRequest error:&error].firstObject;
    if (error) NSLog(@"settings fetcher errror: %@",error);
    if (settings.exerciseTypeColors) self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:settings.exerciseTypeColors];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:singleTap];
    [self loadSearchBar];
    self.supersettingEnabled = NO;
}

- (void)loadSearchBar {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.barTintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
    self.searchController.searchBar.tintColor = self.addExerciseButton.backgroundColor;
    self.searchController.searchBar.layer.borderWidth = 1;
    self.searchController.searchBar.layer.borderColor = self.searchController.searchBar.barTintColor.CGColor;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"Search for an exercise";
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    self.addExerciseButton.layer.cornerRadius = 12;
    self.addExerciseButton.clipsToBounds = YES;
    self.addExerciseButton.userInteractionEnabled = NO;
    self.addExerciseButton.alpha = 0;
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)supersetButtonPressed:(UIButton *)sender {
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    self.addExerciseButton.userInteractionEnabled = NO;
    self.addExerciseButton.alpha = 0;
    self.supersettingEnabled = !self.supersettingEnabled;
    self.tableView.allowsMultipleSelection = self.supersettingEnabled;
    [self.supersetButton setTitle:(self.supersettingEnabled) ? @"One Set?" : @"Superset?" forState:UIControlStateNormal];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    NSMutableArray <NSArray *> *exerciseTIs = [[NSMutableArray alloc] init];
    for (NSIndexPath *path in self.tableView.indexPathsForSelectedRows) {
        NSString *iteration = self.selectedIterations[path];
        [exerciseTIs addObject: @[[self.fetchedResultsController objectAtIndexPath:path], (iteration) ? iteration : [NSNull null]]];
    }
    [self.delegate addExerciseViewController:self willDismissWithSelectedTypeIterationCombinations:exerciseTIs];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTExerciseType" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
                                                               initWithFetchRequest:fetchRequest managedObjectContext:self.context
                                                               sectionNameKeyPath:@"category" cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - searchController methods

- (void)searchForText: (NSString *) string scope: (NSInteger) index {
    self.searchString = string;
    NSError *error;
    if (self.searchString.length)
        [self.fetchedResultsController.fetchRequest setPredicate:
            [NSPredicate predicateWithFormat:@"name CONTAINS %@ OR category CONTAINS %@", string, string]];
    else [self.fetchedResultsController.fetchRequest setPredicate:nil];
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - searchBar delegate mathods

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 45, 0);
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_fetchedResultsController sections].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_fetchedResultsController sections][section].name;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    [header.textLabel setTextColor:[UIColor whiteColor]];
    NSString *key = [_fetchedResultsController sections][section].name;
    header.contentView.backgroundColor = self.exerciseTypeColors[key];
    
    // Another way to set the background color
    // Note: does not preserve gradient effect of original header
    // header.contentView.backgroundColor = [UIColor blackColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_fetchedResultsController sections] objectAtIndex:section].numberOfObjects;
}

- (void)configureCell:(AddExerciseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExerciseType *type = self.fetchedResultsController.sections[indexPath.section].objects[indexPath.row];
    cell.frame = CGRectMake(0, 0, self.tableView.frame.size.width, 50);
    NSString *key = [_fetchedResultsController sections][indexPath.section].name;
    cell.color = self.exerciseTypeColors[key];
    if (!cell.color) cell.color = [UIColor groupTableViewBackgroundColor];
    [cell loadExerciseType:type];
    if (self.selectedIterations[indexPath])
        [cell loadIteration:self.selectedIterations[indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"AddExerciseTableViewCell" owner:self options:nil].firstObject;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tap gesture delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    return [tableView indexPathForRowAtPoint:p];
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (UIGestureRecognizerStateEnded == sender.state) {
        UITableView *tableView = (UITableView *)sender.view;
        NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:[sender locationInView:sender.view]];
        AddExerciseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        CGPoint pointInCell = [sender locationInView:cell];
        if (!cell.cellSelected && pointInCell.x > cell.frame.size.width-120)
            [self presentIterationSelectionViewControllerWithOriginPoint:[sender locationInView:self.view] indexPath:indexPath];
    }
}

#pragma mark - tableView delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView.indexPathsForSelectedRows containsObject:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.selectedIterations removeObjectForKey:indexPath];
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        return nil;
    }
    else if (tableView.indexPathsForSelectedRows.count == 5) {
        [tableView deselectRowAtIndexPath:tableView.indexPathsForSelectedRows.firstObject animated:YES];
        [self.selectedIterations removeObjectForKey:tableView.indexPathsForSelectedRows.firstObject];
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int numSelected = (int)tableView.indexPathsForSelectedRows.count;
    if (numSelected == 1) {
        self.addExerciseButton.alpha = 1;
        self.addExerciseButton.userInteractionEnabled = YES;
    }
    [self.addExerciseButton setTitle:(numSelected == 1) ? @"Add Exercise" :
                               [NSString stringWithFormat:@"Superset %d Exercises",numSelected]
                            forState:UIControlStateNormal];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    int numSelected = (int)tableView.indexPathsForSelectedRows.count;
    if (numSelected == 0) {
        self.addExerciseButton.userInteractionEnabled = NO;
        self.addExerciseButton.alpha = 0;
    }
    else [self.addExerciseButton setTitle:(numSelected == 1) ? @"Add Exercise" :
                                    [NSString stringWithFormat:@"Superset %d Exercises",numSelected]
                                 forState:UIControlStateNormal];
}

#pragma mark - iterationSelectionVC delegate

- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:iterationVC.exerciseType];
    AddExerciseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell loadIteration:iteration];
    self.selectedIterations[indexPath] = iteration;
}

#pragma mark - view handling

- (void)presentIterationSelectionViewControllerWithOriginPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath {
    IterationSelectionViewController *isVC = [self.storyboard instantiateViewControllerWithIdentifier:@"is"];
    isVC.delegate = self;
    isVC.exerciseType = [_fetchedResultsController objectAtIndexPath:indexPath];
    isVC.originPoint = point;
    NSString *key = _fetchedResultsController.sections[indexPath.section].name;
    isVC.color = self.exerciseTypeColors[key];
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

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
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
