//
//  MasterViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/5/14.
//  Copyright (c) 2014 CD. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Workout.h"

@interface MasterViewController ()
            
@property NSMutableArray *objects;

@end

@implementation MasterViewController
            
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

- (void)insertNewObject:(id)sender {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Please enter the name of your workout." delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].placeholder = @"";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *input = [alertView textFieldAtIndex:0].text;
    if (input.length != 0) [self addObjectToArrayWithName:input];
    else [self addObjectToArrayWithName:@"Untitled Workout"];
}

- (void)addObjectToArrayWithName:(NSString *)name{
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject: [[Workout alloc] initWithTitle:name Date:[NSDate date]] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Workout *object = self.objects[indexPath.row];
    [[segue destinationViewController] setDetailItem:object];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    Workout *workout = self.objects[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", workout.title];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"h:mma   MMM d, yyyy"];
    cell.detailTextLabel. text = [NSString stringWithFormat:@"%@  -  %ld steps", [dateFormat stringFromDate:workout.date],workout.steps.count];
    NSLog(@"%ld",workout.steps.count);
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
