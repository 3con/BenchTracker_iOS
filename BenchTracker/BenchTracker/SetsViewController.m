//
//  SetsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/7/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "SetsViewController.h"
#import "Workout.h"
#import "Step.h"

@interface SetsViewController ()

@end

@implementation SetsViewController

Step *step;

NSMutableArray *reps;
NSMutableArray *weight;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = step.name;
    self.pickerViewL.delegate = self;
    self.pickerViewR.delegate = self;
    self.pickerViewL.dataSource = self;
    self.pickerViewR.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    reps = [[NSMutableArray alloc] init];
    weight = [[NSMutableArray alloc] init];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    for (int i = 1; i <= 50; i++) [reps addObject:[NSNumber numberWithInt:i]];
    for (int i = 5; i <= 300; i+= 5) [weight addObject:[NSNumber numberWithInt:i]];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor whiteColor];
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Select Step";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    navItem.rightBarButtonItem = rightButton;
    navBar.items = @[ navItem ];
    [self.view addSubview:navBar];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    if([pickerView isEqual: self.pickerViewL]) return reps.count;
    else return weight.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component {
    if([pickerView isEqual: self.pickerViewL]) return [NSString stringWithFormat:@"%@ reps",reps[row]];
    else return [NSString stringWithFormat:@"%@ lbs.",weight[row]];
}

- (IBAction)addButtonPressed:(UIButton *)sender {
    int r1 = (int)[self.pickerViewL selectedRowInComponent:0];
    int r2 = (int)[self.pickerViewR selectedRowInComponent:0];
    [step addSetWithReps:r1+1 Weight:r2*5+5];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:step.reps.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) setDetailItem:(Step *)detailItem{
    step = [[Step alloc] init];
    step = detailItem;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return step.reps.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    int i = (int)indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@ reps at %@ lbs.", i+1, step.reps[i],step.weight[i]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [step.reps removeObjectAtIndex:indexPath.row];
        [step.weight removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)doneButtonPressed: (id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end