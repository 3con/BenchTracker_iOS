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

@property (nonatomic) NSMutableArray <BTExerciseType *> *selectedTypes;
@property (nonatomic) NSMutableArray <NSString *> *selectedIterations;

@property (nonatomic) NSString *searchString;

@end

@implementation AddExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    self.tableView.allowsMultipleSelection = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    singleTap.delegate = self;
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:singleTap];
    [self loadSearchBar];
}

- (void)loadSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:84/255.0 alpha:1];
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
    self.tableView.tableHeaderView = self.searchBar;
    [self.searchBar sizeToFit];
    self.searchBar.placeholder = @"Search for an exercise";
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.containerView.layer.cornerRadius = 12;
    self.containerView.clipsToBounds = YES;
    for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.userInteractionEnabled = NO;
        button.alpha = 0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)supersetButtonPressed:(UIButton *)sender {
    [self.delegate addExerciseViewController:self willDismissWithSelectedTypeIterationCombinations:[self typeIterationPairs] superset:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [self.delegate addExerciseViewController:self willDismissWithSelectedTypeIterationCombinations:[self typeIterationPairs] superset:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearButtonPressed:(UIButton *)sender {
    [self clearTypeIterations];
}

- (NSArray <NSArray *> *)typeIterationPairs {
    NSMutableArray <NSArray *> *exerciseTIs = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.selectedTypes.count; i++) {
        NSString *iteration = self.selectedIterations[i];
        [exerciseTIs addObject: @[self.selectedTypes[i], (iteration && iteration.length > 0) ? iteration : [NSNull null]]];
    }
    return exerciseTIs;
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BTExerciseType" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort1 = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSSortDescriptor *sort2 = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort1, sort2]];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
                                                               initWithFetchRequest:fetchRequest managedObjectContext:self.context
                                                               sectionNameKeyPath:@"category" cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - searchController methods

- (void)searchForText:(NSString *)string {
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

- (void)updateSearchResults {
    CGRect searchBarFrame = self.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    NSString *searchString = self.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

#pragma mark - searchBar delegate mathods

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
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"AddExerciseTableViewCell" owner:self options:nil].firstObject;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    BTExerciseType *type = self.fetchedResultsController.sections[indexPath.section].objects[indexPath.row];
    [cell setSelected:[self typeExists:type] animated:YES];
    [(AddExerciseTableViewCell *)cell loadIteration:[self iterationForType:type]];
}

#pragma mark - tap gesture delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint p = [gestureRecognizer locationInView:gestureRecognizer.view];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:p];
    AddExerciseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[NSKeyedUnarchiver unarchiveObjectWithData:cell.exerciseType.iterations] count] == 0) return NO;
    return indexPath && p.x > cell.frame.size.width-120 && !cell.cellSelected;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (UIGestureRecognizerStateEnded == sender.state) {
        NSIndexPath *indexPath = [(UITableView *)sender.view indexPathForRowAtPoint:[sender locationInView:sender.view]];
        [self presentIterationSelectionViewControllerWithOriginPoint:[sender locationInView:self.view] indexPath:indexPath];
    }
}

#pragma mark - tableView delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTExerciseType *type = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([self typeExists:type]) {
        [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
        //[tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self removeType:type];
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        return nil;
    }
    else if (self.selectedTypes.count == 5) return nil;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
    BTExerciseType *type = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self addType:type andIteration:@""];
    NSInteger numSelected = self.selectedTypes.count;
    if (numSelected == 1) {
        for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
            button.userInteractionEnabled = YES;
            button.alpha = 1;
        }
    }
    [self.addExerciseButton setTitle:(numSelected == 1) ? @"Add\nExercise" :
                                [NSString stringWithFormat:@"Add\n%ld Exercises",numSelected]
                                    forState:UIControlStateNormal];
    [self.supersetButton setTitle:[NSString stringWithFormat:@"Superset\n%ld Exercises",numSelected]
                                    forState:UIControlStateNormal];
    self.supersetButton.alpha = (numSelected != 1);
    self.supersetButton.userInteractionEnabled = (numSelected != 1);
    self.addExerciseConstraint.constant = (numSelected != 1) ? 135 : 5;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numSelected = self.selectedTypes.count;
    if (numSelected == 0) {
        for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
            button.userInteractionEnabled = NO;
            button.alpha = 0;
        }
    }
    else {
        [self.addExerciseButton setTitle:(numSelected == 1) ? @"Add\nExercise" :
                                    [NSString stringWithFormat:@"Add\n%ld Exercises",numSelected]
                                        forState:UIControlStateNormal];
        [self.supersetButton setTitle:[NSString stringWithFormat:@"Superset\n%ld Exercises",numSelected]
                                        forState:UIControlStateNormal];
        self.supersetButton.alpha = (numSelected != 1);
        self.supersetButton.userInteractionEnabled = (numSelected != 1);
        self.addExerciseConstraint.constant = (numSelected != 1) ? 135 : 5;
    }
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
}

#pragma mark - iterationSelectionVC delegate

- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:iterationVC.exerciseType];
    AddExerciseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self removeType:iterationVC.exerciseType];
    [self addType:iterationVC.exerciseType andIteration:iteration];
    [cell loadIteration:iteration];
}

- (void)iterationSelectionVCDidDismiss:(IterationSelectionViewController *)iterationVC {
    
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
        case NSFetchedResultsChangeUpdate: break;
        case NSFetchedResultsChangeMove: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
     
#pragma mark - TI methods

- (BOOL)typeExists:(BTExerciseType *)type {
    return [self.selectedTypes containsObject:type];
}
     
- (NSString *)iterationForType:(BTExerciseType *)type {
    if (![self typeExists:type]) return nil;
    NSInteger index = [self.selectedTypes indexOfObject:type];
    NSString *s = self.selectedIterations[index];
    return (!s || s.length == 0) ? nil : s;
}
     
- (void)addType:(BTExerciseType *)type andIteration:(NSString *)iteration {
    if(!self.selectedTypes) self.selectedTypes = [NSMutableArray array];
    if(!self.selectedIterations) self.selectedIterations = [NSMutableArray array];
    [self.selectedTypes addObject:type];
    [self.selectedIterations addObject:iteration];
}

- (void)removeType:(BTExerciseType *)type {
    NSInteger index = [self.selectedTypes indexOfObject:type];
    [self.selectedTypes removeObjectAtIndex:index];
    [self.selectedIterations removeObjectAtIndex:index];
}
     
- (void)clearTypeIterations {
    [self.selectedTypes removeAllObjects];
    [self.selectedIterations removeAllObjects];
    for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
        button.userInteractionEnabled = NO;
        button.alpha = 0;
    }
    [self.tableView reloadData];
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
