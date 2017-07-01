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
#import "ExerciseTableViewCell.h"
#import "PassTouchesView.h"

@interface WorkoutViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property BTWorkoutManager *workoutManager;

@property (nonatomic) NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets;

@property (nonatomic) NSMutableArray <BTExercise *> *selectedExercises;
@property (nonatomic) NSMutableArray <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic) NSDate *startDate;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.nameTextField.delegate = self;
    self.finishWorkoutButton.layer.cornerRadius = 12;
    self.finishWorkoutButton.clipsToBounds = YES;
    self.workoutManager = [BTWorkoutManager sharedInstance];
    if (!self.workout) self.workout = [self.workoutManager createWorkout];
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.workout.name
        attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont italicSystemFontOfSize:22]}];
    self.tempSupersets = [NSKeyedUnarchiver unarchiveObjectWithData:self.workout.supersets];
    for (NSMutableArray <NSNumber *> *superset in self.tempSupersets) {
        NSLog(@"%@",superset);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.startDate = [NSDate date];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [self presentAddExerciseViewController];
}

- (IBAction)finishWorkoutButtonPressed:(UIButton *)sender {
    NSTimeInterval timeInterval = [self.startDate timeIntervalSinceNow];
    self.workout.duration += -timeInterval+1;
    if (self.nameTextField.text.length > 0) self.workout.name = self.nameTextField.text;
    NSMutableDictionary <NSString *, NSNumber *> *dict = [[NSMutableDictionary alloc] init];
    for (BTExercise *exercise in self.workout.exercises) {
        if (dict[exercise.category]) dict[exercise.category] = [NSNumber numberWithInt:dict[exercise.category].intValue + 1];
        else                         dict[exercise.category] = [NSNumber numberWithInt:1];
    }
    self.workout.summary = @"0";
    if (self.workout.exercises.count > 0) {
        for (NSString *key in dict.allKeys)
            self.workout.summary = [NSString stringWithFormat:@"%@#%@ %@",self.workout.summary, key, dict[key]];
        self.workout.summary = [self.workout.summary substringFromIndex:2];
    }
    self.workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:self.tempSupersets];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workout.exercises.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"ExerciseTableViewCell" owner:self options:nil].firstObject;
    cell.supersetMode = [self supersetTypeForIndexPath:indexPath];
    [cell loadExercise:self.workout.exercises[indexPath.row]];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 95;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    PassTouchesView *footerView = [[PassTouchesView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 95)];
    footerView.backgroundColor = [UIColor clearColor];
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.0-75, 20, 150, 50)];
    [add setTitle:@"Add Exercise" forState:UIControlStateNormal];
    [add setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    add.layer.cornerRadius = 12;
    add.clipsToBounds = YES;
    add.backgroundColor = [UIColor colorWithRed:251/255.0 green:192/255.0 blue:45/255.0 alpha:1];
    [add addTarget:self action:@selector(addExerciseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:add];
    return footerView;
}

- (NSString *)supersetTypeForIndexPath:(NSIndexPath *)indexPath {
    NSArray <NSNumber *> *superset = [self supersetForIndexPath:indexPath];
    if (!superset) return SUPERSET_NONE;
    NSInteger index = [superset indexOfObject:[NSNumber numberWithInt:(int)indexPath.row]];
    if (index == 0) return SUPERSET_ABOVE;
    else if (index == superset.count-1) return SUPERSET_BELOW;
    return SUPERSET_BOTH;
}

- (NSArray <NSNumber *> *)supersetForIndexPath:(NSIndexPath *)indexPath {
    for (NSArray *arr in self.tempSupersets)
        if([arr containsObject:[NSNumber numberWithInt:(int)indexPath.row]]) return arr;
    return nil;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPaths = [[NSMutableArray alloc] init];
    self.selectedExercises = [[NSMutableArray alloc] init];
    for (NSNumber *n in [self supersetForIndexPath:indexPath]) {
        [self.selectedExercises addObject:self.workout.exercises[n.intValue]];
        [self.selectedIndexPaths addObject:[NSIndexPath indexPathForRow:n.intValue inSection:0]];
    }
    if (self.selectedExercises.count == 0) {
        [self.selectedExercises addObject:self.workout.exercises[indexPath.row]];
        [self.selectedIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentExerciseViewControllerWithExercises:self.selectedExercises];
    });
}

#pragma mark - addVC delegate

- (void)addExerciseViewController:(AddExerciseViewController *)addVC willDismissWithSelectedTypes:(NSArray<BTExerciseType *> *)selectedTypes {
    NSMutableArray <NSNumber *> *supersetArr = [[NSMutableArray alloc] init];
    NSMutableArray <NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    for (BTExerciseType *type in selectedTypes) {
        [self.workout addExercisesObject:[self exerciseForExerciseType:type]];
        [supersetArr addObject:[NSNumber numberWithInt:(int)self.workout.exercises.count-1]];
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.workout.exercises.count-1 inSection:0]];
    }
    if (supersetArr.count > 1) [self.tempSupersets addObject:supersetArr];
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        [self.tableView reloadData];
    }];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
    [CATransaction commit];
}

- (BTExercise *)exerciseForExerciseType: (BTExerciseType *)type {
    BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:self.context];
    exercise.name = type.name;
    exercise.iteration = [NSKeyedUnarchiver unarchiveObjectWithData:type.iterations][0];
    exercise.category = type.category;
    exercise.style = type.style;
    exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    exercise.workout = self.workout;
    return exercise;
}

#pragma mark - exerciseVC delegate

- (void)exerciseViewController:(ExerciseViewController *)exerciseVC willDismissWithEditedExercises:(NSArray<BTExercise *> *)exercises
                                                                                  deletedExercises:(NSArray<BTExercise *> *)deleted {
    NSMutableArray <NSIndexPath *> *deletedIndexPaths = [[NSMutableArray alloc] init];
    for (BTExercise *exercise in deleted) {
        NSInteger index = [self.workout.exercises indexOfObject:exercise];
        [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        [self.selectedIndexPaths removeObject:deletedIndexPaths.lastObject];
    }
    [deletedIndexPaths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 row] < [obj2 row]) return (NSComparisonResult)NSOrderedDescending;
        if ([obj1 row] > [obj2 row]) return (NSComparisonResult)NSOrderedAscending;
        return (NSComparisonResult)NSOrderedSame;
    }];
    for (NSIndexPath *index in deletedIndexPaths) {
        for (NSMutableArray <NSNumber *> *superset in self.tempSupersets) {
            for (int i = (int)superset.count-1; i >= 0; i--) {
                if (superset[i].integerValue == index.row) [superset removeObjectAtIndex:i];
                else if (superset[i].integerValue > index.row) superset[i] = [NSNumber numberWithInt:superset[i].intValue - 1];
            }
        }
    }
    for (NSInteger i = self.tempSupersets.count-1; i >= 0; i--)
        if (self.tempSupersets[i].count <= 1) [self.tempSupersets removeObjectAtIndex:i];
    for (BTExercise *exercise in deleted) {
        [self.workout removeExercisesObject:exercise];
        [self.context deleteObject:exercise];
    }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadRowsAtIndexPaths:self.selectedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
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
    self.animator.behindViewAlpha = 0.4;
    self.animator.behindViewScale = 1;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    addVC.transitioningDelegate = self.animator;
    addVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:addVC animated:YES completion:nil];
}

- (void)presentExerciseViewControllerWithExercises: (NSArray<BTExercise *> *)exercises {
    ExerciseViewController *eVC = [self.storyboard instantiateViewControllerWithIdentifier:@"e"];
    eVC.exercises = exercises;
    eVC.delegate = self;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:eVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.4;
    self.animator.behindViewScale = 1;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    eVC.transitioningDelegate = self.animator;
    eVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:eVC animated:YES completion:nil];
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
