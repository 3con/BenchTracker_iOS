//
//  EditExercisesViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/14/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EditExercisesViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "BTSettings+CoreDataClass.h"
#import "EEExerciseTypeTableViewCell.h"
#import "BTExerciseType+CoreDataClass.h"

@interface EditExercisesViewController ()

@property (weak, nonatomic) IBOutlet UIView *navBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchRequest *cachedFetchRequest;

@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) UISearchBar *searchBar;

@property (nonatomic) NSString *searchString;

@end

@implementation EditExercisesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navBar.backgroundColor = [UIColor BTPrimaryColor];
    self.navBar.layer.borderWidth = 1.0;
    self.navBar.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.doneButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    [self.createButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    self.searchString = @"";
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor clearColor];
    [self loadSearchBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"EE fetch error: %@, %@", error, [error userInfo]);
    }
    self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:[BTSettings sharedInstance].exerciseTypeColors];
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

- (IBAction)editButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newButtonPressed:(UIButton *)sender {
    [self presentExerciseDetailViewControllerWithType:nil];
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
    return _fetchedResultsController.sections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
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
    return _fetchedResultsController.sections[section].numberOfObjects;
}

- (void)configureCell:(EEExerciseTypeTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExerciseType *type = self.fetchedResultsController.sections[indexPath.section].objects[indexPath.row];
    [cell loadWithName:type.name];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EEExerciseTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"EEExerciseTypeTableViewCell" owner:self options:nil].firstObject;
    cell.delegate = self;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTExerciseType *type = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self presentExerciseDetailViewControllerWithType:type];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchBar.isFirstResponder) [self.searchBar resignFirstResponder];
}

#pragma mark - view handling

- (void)presentExerciseDetailViewControllerWithType:(BTExerciseType *)type {
    EEDetailViewController *eedVC = [self.storyboard instantiateViewControllerWithIdentifier:@"eed"];
    eedVC.delegate = self;
    eedVC.context = self.context;
    eedVC.type = type;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:eedVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    eedVC.transitioningDelegate = self.animator;
    eedVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:eedVC animated:YES completion:nil];
}

#pragma mark - eedVC delegate

- (void)editExerciseDetailViewControllerWillDismiss:(EEDetailViewController *)eedVC {
    
}

#pragma mark - MGSwipeTableCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Exercise"
                                                                   message:@"Are you sure you want to delete this exercise? You will no longer be able to see your progress for this exercise. This action can be undone but it is not easy."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
            [self.context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            [self.context save:nil];
        });
    }];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelButton];
    [alert addAction:deleteButton];
    [self presentViewController:alert animated:YES completion:nil];
    return YES;
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    switch(type) {
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    return [UIColor statusBarStyle];
}

@end
