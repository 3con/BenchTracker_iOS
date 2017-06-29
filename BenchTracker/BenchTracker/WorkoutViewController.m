//
//  WorkoutViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutViewController.h"
#import "BTWorkoutManager.h"
#import "BTExercise+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"

@interface WorkoutViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property BTWorkoutManager *workoutManager;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.nameTextField.delegate = self;
    self.workoutManager = [BTWorkoutManager sharedInstance];
    if (!self.workout) self.workout = [self.workoutManager createWorkout];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [self presentAddExerciseViewController];
}

- (IBAction)finishWorkoutButtonPressed:(UIButton *)sender {
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workout.exercises.count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExercise *exercise = self.workout.exercises[indexPath.row];
    cell.textLabel.text = exercise.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", exercise.category];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WorkoutCell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: @"WorkoutCell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - addVC delegate

- (void)addExerciseViewController:(AddExerciseViewController *)addVC willDismissWithSelectedTypes:(NSArray<BTExerciseType *> *)selectedTypes {
    for (BTExerciseType *type in selectedTypes) {
        BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:self.context];
        exercise.name = type.name;
        exercise.iteration = [NSKeyedUnarchiver unarchiveObjectWithData:type.iterations][0];
        exercise.category = type.category;
        exercise.style = type.style;
        exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:@[]];
        exercise.workout = self.workout;
        [self.workout addExercisesObject:exercise];
    }
    [self.tableView reloadData];
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameTextField resignFirstResponder];
    return YES;
}

#pragma mark - view handling

- (void)presentAddExerciseViewController {
    AddExerciseViewController *addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ae"];
    addVC.delegate = self;
    addVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:addVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.5;
    self.animator.behindViewScale = 1;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    addVC.transitioningDelegate = self.animator;
    addVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:addVC animated:YES completion:nil];
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
