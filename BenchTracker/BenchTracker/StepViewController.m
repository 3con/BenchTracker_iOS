//
//  StepViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/6/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "StepViewController.h"

@interface StepViewController ()

@end

@implementation StepViewController

UINavigationItem *navItem;

NSMutableArray *choices;
NSString *selectedStep;
NSIndexPath *path;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrArm = [[NSMutableArray alloc] initWithObjects: @"Barbell Bicep Curl", @"Alternated Dumbbell Curl",
                   @"Simultanious Dumbbell Curl", @"Hammer Curl", @"Tricep Kickback",
                   @"Lying Tricep Extenision", @"Standing Tricep Extension", nil];
    self.arrLeg = [[NSMutableArray alloc] initWithObjects: @"Barbell Squat", @"Dumbbell Squat",
                   @"Barbell Straight Lunge", @"Dumbbell Straight Lunge",
                   @"Dumbbell Side Lunge", @"Barbell Calf Raises", @"Dumbbell Calf Raises",
                   @"Barbell Step Up", @"Dumbbell Step Up", nil];
    self.arrLowerChest = [[NSMutableArray alloc] initWithObjects: @"Dumbbell Russian Twist",
                          @"Weighted Plank (30 sec)", @"Weighted Plank (60 sec)", @"Plank And Rotate",
                          @"Dumbbell Sit Up", nil];
    self.arrUpperChest = [[NSMutableArray alloc] initWithObjects: @"Flat Bench Press", @"Incline Bench Press",
                          @"Decline Bench Press", @"Flat Dumbbell Press", @"Incline Dumbbell Press",
                          @"Decline Dumbbell press", @"Lying Fly", nil];
    self.arrShoulders = [[NSMutableArray alloc] initWithObjects: @"Barbell Upright Row", @"Seated Military Press",
                         @"Standing Military Press", @"Shoulder Press", @"Lateral Raise",@"Front Raise",
                         @"Shoulder Shrug", nil];
    choices = [[NSMutableArray alloc] initWithObjects: self.arrArm, self.arrLeg, self.arrUpperChest, self.arrLowerChest, self.arrShoulders, nil];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(64,0,0,0)];
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
    navBar.backgroundColor = [UIColor whiteColor];
    navItem = [[UINavigationItem alloc] init];
    navItem.title = @"Select Step";
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonPressed:)];
    navItem.rightBarButtonItem = rightButton;
    navItem.rightBarButtonItem.enabled = NO;
    navBar.items = @[ navItem ];
    [self.view addSubview:navBar];
}

- (void)doneButtonPressed: (id)sender {
    selectedStep = choices[self.tableView.indexPathForSelectedRow.section][self.tableView.indexPathForSelectedRow.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - segue

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    path = indexPath;
    NSLog(@"Accessory button is tapped for cell at index path = %@", indexPath);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"StepDetailViewController"];
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return choices.count;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = choices[section];
    return arr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"Arms";
    else if (section == 1) return @"Legs";
    else if (section == 2) return @"Upper Chest";
    else if (section == 3) return @"Lower Chest";
    else return @"Shoulders";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",choices[indexPath.section][indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    navItem.rightBarButtonItem.enabled = YES;
}

@end
