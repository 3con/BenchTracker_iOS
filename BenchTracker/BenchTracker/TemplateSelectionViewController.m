//
//  TemplateSelectionViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "TemplateSelectionViewController.h"
#import "BTWorkoutTemplate+CoreDataClass.h"
#import "WorkoutTemplateTableViewCell.h"
#import "BTSettings+CoreDataClass.h"

@interface TemplateSelectionViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TemplateSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Template selection fetch error: %@, %@", error, [error userInfo]);
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"EmptyTemplateTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ACell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WorkoutTemplateTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
    CGRect frame = self.tableView.bounds;
    frame.origin.y = -frame.size.height;
    UIView *coverView = [[UIView alloc] initWithFrame:frame];
    coverView.backgroundColor = [UIColor BTPrimaryColor];
    [self.tableView addSubview:coverView];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView dataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 52;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)];
    view.backgroundColor = [UIColor BTPrimaryColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 52)];
    label.text = (section == 0) ? @"Your Templates" : @"Default Templates";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:21 weight:UIFontWeightSemibold];
    [view addSubview:label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.fetchedResultsController.sections.count == 1) { //no user templates
        if (section == 0) return 1;
        return self.fetchedResultsController.sections[0].objects.count;
    }
    return self.fetchedResultsController.sections[section].objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchedResultsController.sections.count == 1 && indexPath.section == 0) return 180; //no user templates
    return [WorkoutTemplateTableViewCell heightForWorkoutTemplate:[self modifiedObjectAtIndex:indexPath]];
}

- (void)configureTemplateCell:(WorkoutTemplateTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (self.settings.exerciseTypeColors)
        cell.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    cell.delegate = self;
    [cell loadWorkoutTemplate:[self modifiedObjectAtIndex:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchedResultsController.sections.count == 1 && indexPath.section == 0) //no user templates
        return [tableView dequeueReusableCellWithIdentifier:@"ACell"];
    WorkoutTemplateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureTemplateCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTWorkout *workout = [BTWorkoutTemplate workoutForWorkoutTemplate:[self modifiedObjectAtIndex:indexPath]];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate templateSelectionViewController:self didDismissWithSelectedWorkout:workout];
    }];
}

#pragma mark - MGSwipeTableCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell canSwipe:(MGSwipeDirection)direction fromPoint:(CGPoint)point {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BTWorkoutTemplate *template = [self modifiedObjectAtIndex:indexPath];
    return [template.source isEqualToString:TEMPLATE_SOURCE_USER];
}

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BTWorkoutTemplate *template = [self modifiedObjectAtIndex:indexPath];
    if (direction == MGSwipeDirectionLeftToRight) {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Delete Template"
                                                                        message:@"Are you sure you want to delete this template? This action cannot be undone."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.context deleteObject:template];
                [self.context save:nil];
            });
        }];
        UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelButton];
        [alert addAction:deleteButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    return YES;
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BTWorkoutTemplate"];
    fetchRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"source" ascending:NO],
                                     [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]];
    NSFetchedResultsController *fC = [[NSFetchedResultsController alloc]
        initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"source" cacheName:nil];
    self.fetchedResultsController = fC;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (BTWorkoutTemplate *)modifiedObjectAtIndex:(NSIndexPath *)indexPath {
    if (self.fetchedResultsController.sections.count == 1)
        return [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
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
            if (self.fetchedResultsController.sections.count == 1)
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureTemplateCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
            //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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

@end
