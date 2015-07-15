//
//  DetailViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/5/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "DetailViewController.h"
#import "Workout.h"
#import "Step.h"
#import "StepViewController.h"

@interface DetailViewController ()

@property Workout *workout;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.workout.title;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self configureView];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    NSLog(@"LOAD: %@",selectedStep);
    if (selectedStep) {
        [self.workout addStepWithName:selectedStep]; //CORRECT NAME FROM STEPVIEWCONTROLLER
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.workout.steps.count-1 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated {
    selectedStep = nil;
    [super viewDidDisappear:YES];
}

- (void)setDetailItem: (Workout *)newDetailItem {
    self.workout = [[Workout alloc] init];
    self.workout = newDetailItem;
    [self configureView];
}

- (void)configureView {
    self.title = self.workout.title;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)insertNewObject:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StepViewController"];
    vc.view.backgroundColor = [UIColor clearColor];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"PREPARING");
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Step *step = self.workout.steps[indexPath.row];
    [[segue destinationViewController] setDetailItem:step];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"ROW UPDATE: %ld",self.workout.steps.count);
    return self.workout.steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Step *step = self.workout.steps[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", step.name];
    if (step.sets == 0) {
        cell.detailTextLabel.text = @"0 sets with about 0 reps at 0 lbs.";
    }
    else {
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d sets with about %.0f reps at %.0f lbs.", step.sets,
                                  floor([[step.reps valueForKeyPath: @"@sum.self"] integerValue]/(float)step.sets+0.5),
                                  floor([[step.weight valueForKeyPath: @"@sum.self"] integerValue]/(float)step.sets+0.5)];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.workout.steps removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier: @"toSets" sender:cell];
}

@end
