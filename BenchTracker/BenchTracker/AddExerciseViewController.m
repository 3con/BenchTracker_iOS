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
#import "EditExercisesViewController.h"
#import "AETableHeaderView.h"

@interface AddExerciseViewController ()

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *supersetButton;
@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addExerciseConstraint;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) NSDictionary *exerciseTypeColors;
@property (nonatomic) NSMutableArray *tempHiddenSections;

@property (nonatomic) NSMutableArray <BTExerciseType *> *selectedTypes;
@property (nonatomic) NSMutableArray <NSString *> *selectedIterations;

@property (nonatomic) NSString *searchString;

@end

@implementation AddExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.containerView.backgroundColor = [UIColor BTPrimaryColor];
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.cancelButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    [self.editButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    self.addExerciseButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.addExerciseButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
    self.supersetButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    [self.supersetButton setTitleColor: [UIColor BTButtonTextSecondaryColor] forState:UIControlStateNormal];
    self.clearButton.backgroundColor = [UIColor BTRedColor];
    self.searchString = @"";
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
    }
    BTSettings *settings = [BTSettings sharedInstance];
    self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:settings.exerciseTypeColors];
    self.tempHiddenSections = [NSKeyedUnarchiver unarchiveObjectWithData:settings.hiddenExerciseTypeSections];
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
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
    [Log event:@"AddExerciseVC: Presentation" properties:nil];
}

- (void)loadSearchBar {
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor BTPrimaryColor];
    self.searchBar.tintColor = [UIColor whiteColor];
    self.searchBar.keyboardAppearance = [UIColor keyboardAppearance];
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = self.searchBar.barTintColor.CGColor;
    self.tableView.tableHeaderView = self.searchBar;
    [self.searchBar sizeToFit];
    self.searchBar.placeholder = @"Search for an exercise";
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    self.containerView.layer.cornerRadius = 16;
    self.containerView.clipsToBounds = YES;
    for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
        button.layer.cornerRadius = 12;
        button.clipsToBounds = YES;
        button.titleLabel.numberOfLines = 2;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [BTSettings sharedInstance].hiddenExerciseTypeSections = [NSKeyedArchiver archivedDataWithRootObject:self.tempHiddenSections];
    [self.context save:nil];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [Log event:@"AddExerciseVC: Cancel" properties:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)editButtonPressed:(UIButton *)sender {
    [Log event:@"AddExerciseVC: Edit" properties:nil];
    [self presentEditExercisesViewController];
}

- (IBAction)supersetButtonPressed:(UIButton *)sender {
    [Log event:@"AddExerciseVC: Done" properties:@{@"Superset": @"True"}];
    [self.delegate addExerciseViewController:self willDismissWithSelectedTypeIterationCombinations:[self typeIterationPairs] superset:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [Log event:@"AddExerciseVC: Done" properties:@{@"Superset": @"False"}];
    [self.delegate addExerciseViewController:self willDismissWithSelectedTypeIterationCombinations:[self typeIterationPairs] superset:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearButtonPressed:(UIButton *)sender {
    [Log event:@"AddExerciseVC: Clear" properties:nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 38;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionName = _fetchedResultsController.sections[section].name;
    AETableHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"AETableHeaderView" owner:self options:nil].firstObject;
    headerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 38);
    headerView.color = self.exerciseTypeColors[sectionName];
    headerView.name = sectionName;
    headerView.expanded = ![self.tempHiddenSections containsObject:sectionName];
    headerView.delegate = self;
    headerView.section = section;
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionName = _fetchedResultsController.sections[section].name;
    if ([self.tempHiddenSections containsObject:sectionName]) return 0;
    return [[_fetchedResultsController sections] objectAtIndex:section].numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"AddExerciseTableViewCell" owner:self
                                                        options:nil].firstObject;
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
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
    UITableView *tableView = (UITableView *)gestureRecognizer.view;
    CGPoint point = [gestureRecognizer locationInView:tableView];
    NSIndexPath *indexPath = [tableView indexPathForRowAtPoint:point];
    AddExerciseTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell || [[NSKeyedUnarchiver unarchiveObjectWithData:cell.exerciseType.iterations] count] == 0) return NO;
    return indexPath && point.x > cell.frame.size.width - 120 && !cell.cellSelected;
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
    [Log event:@"AddExerciseVC: Selected type" properties:@{@"Type": type.name}];
    [self addType:type andIteration:@""];
    [self updateButtons];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
    BTExerciseType *type = [_fetchedResultsController objectAtIndexPath:indexPath];
    [Log event:@"AddExerciseVC: Deselected type" properties:@{@"Type": type.name}];
    [self updateButtons];
}

- (void)updateButtons {
    NSInteger numSelected = self.selectedTypes.count;
    for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
        button.hidden = (numSelected == 0);
    }
    [self.addExerciseButton setTitle:(numSelected == 1) ? @"Add\nExercise" : [NSString stringWithFormat:@"Add\n%ld Exercises",(long)numSelected]
                            forState:UIControlStateNormal];
    [self.supersetButton setTitle:[NSString stringWithFormat:@"Superset\n%ld Exercises",(long)numSelected]
                         forState:UIControlStateNormal];
    self.supersetButton.hidden = (numSelected < 2);
    self.addExerciseConstraint.constant = (numSelected < 2) ? 5 : 135;
}

#pragma mark - headerView delegate

- (void)headerView:(AETableHeaderView *)headerView didChangeExpanded:(BOOL)expanded {
    [Log event:@"AddExerciseVC: Expanded header" properties:@{@"Expanded": @(expanded),
                                                              @"Body part": headerView.name}];
    [self.tableView beginUpdates];
    if (expanded && [self.tempHiddenSections containsObject:headerView.name]) {
        [self.tempHiddenSections removeObject:headerView.name];
        [self.tableView insertRowsAtIndexPaths:[self indexPathsForSection:headerView.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [self.tempHiddenSections addObject:headerView.name];
        [self.tableView deleteRowsAtIndexPaths:[self indexPathsForSection:headerView.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView endUpdates];
}

- (NSArray *)indexPathsForSection:(NSInteger)section {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < _fetchedResultsController.sections[section].objects.count; i++)
        [arr addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    return arr;
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
}

#pragma mark - iterationSelectionVC delegate

- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration {
    NSIndexPath *indexPath = [_fetchedResultsController indexPathForObject:iterationVC.exerciseType];
    AddExerciseTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    BOOL animate = ![self removeType:iterationVC.exerciseType];
    [self addType:iterationVC.exerciseType andIteration:iteration];
    if (animate) {
        [self updateButtons];
        cell.selected = true;
    }
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

- (void)presentEditExercisesViewController {
    EditExercisesViewController *eeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ee"];
    //eeVC.delegate = self;
    eeVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:eeVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 1.0; //0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    eeVC.transitioningDelegate = self.animator;
    eeVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:eeVC animated:YES completion:nil];
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
     
#pragma mark - type iteration methods

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

- (BOOL)removeType:(BTExerciseType *)type {
    if (![self typeExists:type]) return NO;
    NSInteger index = [self.selectedTypes indexOfObject:type];
    [self.selectedTypes removeObjectAtIndex:index];
    [self.selectedIterations removeObjectAtIndex:index];
    return YES;
}
     
- (void)clearTypeIterations {
    [self.selectedTypes removeAllObjects];
    [self.selectedIterations removeAllObjects];
    for (UIButton *button in @[self.supersetButton, self.addExerciseButton, self.clearButton]) {
        button.hidden = YES;
    }
    [self.tableView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
