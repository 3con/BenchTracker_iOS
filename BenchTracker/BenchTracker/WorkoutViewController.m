//
//  WorkoutViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutViewController.h"
#import "BTExercise+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTAchievement+CoreDataClass.h"
#import "ZFModalTransitionAnimator.h"
#import "EditSmartNamesViewController.h"
#import "ExerciseTableViewCell.h"
#import "PassTouchesView.h"
#import "BTSettings+CoreDataClass.h"
#import "AppDelegate.h"

@interface WorkoutViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *adjustTimesButton;

@property (weak, nonatomic) IBOutlet UIButton *finishWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteWorkoutButton;

@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (nonatomic) NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets;

@property (nonatomic) NSMutableArray <BTExercise *> *selectedExercises;
@property (nonatomic) NSMutableArray <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic) BOOL paused;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorSchemeChange:)
                                                 name:@"colorSchemeChange" object:nil];
    [self updateInterface];
    self.paused = NO;
    self.pauseView.alpha = 0;
    self.pauseView.userInteractionEnabled = NO;
    self.settings = [BTSettings sharedInstance];
    self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    UILongPressGestureRecognizer *lP = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lP.minimumPressDuration = .15;
    lP.delegate = self;
    [self.tableView addGestureRecognizer:lP];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(2.5, 0, 92.5, 0);
    self.addExerciseButton.layer.cornerRadius = 12;
    self.addExerciseButton.clipsToBounds = YES;
    self.nameTextField.delegate = self;
    self.finishWorkoutButton.layer.cornerRadius = 12;
    self.finishWorkoutButton.clipsToBounds = YES;
    self.deleteWorkoutButton.layer.cornerRadius = 12.5;
    self.deleteWorkoutButton.clipsToBounds = YES;
    if (!self.context) self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    if (!self.workout) self.workout = [BTWorkout workout];
    [BTUser removeWorkoutFromTotals:self.workout];
    self.settings.activeWorkoutBeforeDuration = self.workout.duration;
    BOOL placeholder = true;
    if (@available(iOS 11, *)) {
        placeholder = !self.settings.showSmartNames;
    }
    if (placeholder) self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.workout.name
        attributes:@{NSForegroundColorAttributeName:[UIColor BTTextPrimaryColor], NSFontAttributeName:[UIFont italicSystemFontOfSize:22]}];
    else if (self.workout.smartName) self.nameTextField.text = self.workout.smartNickname;
    else self.nameTextField.text = self.workout.name;
    if (!placeholder) self.nameTextField.placeholder = @"";
    self.tempSupersets = [NSKeyedUnarchiver unarchiveObjectWithData:self.workout.supersets];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleWillTerminate:)
                                                 name: UIApplicationWillTerminateNotification
                                               object: nil];
}

- (void)updateInterface {
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.finishWorkoutButton.backgroundColor = [UIColor BTSecondaryColor];
    [self.finishWorkoutButton setTitleColor: [UIColor BTButtonTextSecondaryColor] forState:UIControlStateNormal];
    self.addExerciseButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.addExerciseButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
    [self.settingsButton setImage:[[UIImage imageNamed:@"More"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                         forState:UIControlStateNormal];
    self.settingsButton.tintColor = [UIColor BTTextPrimaryColor];
    self.deleteWorkoutButton.backgroundColor = [UIColor BTRedColor];
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
}

- (void)colorSchemeChange:(NSNotification *)notification  {
    [self updateInterface];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.addExerciseButton.hidden = NO;
    if (self.settings.disableSleep) [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.settings.activeWorkout = self.workout;
    [self.context save:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.addExerciseButton.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self workoutWillEnd];
}

- (void)workoutWillEnd {
    if (self.settings.activeWorkout) {
        self.settings.activeWorkout = nil;
        self.settings.activeWorkoutStartDate = nil;
        self.settings.activeWorkoutLastUpdate = nil;
        [self updateWorkout];
        [BTUser addWorkoutToTotals:self.workout];
    }
}

- (void)handleEnteredBackground:(id)sender {
    [self updateWorkout];
    [self performSelector:@selector(delayedSave) withObject:nil afterDelay:.2];
}

- (void)delayedSave {
    [self.context save:nil];
}

- (void)handleWillTerminate:(id)sender {
    [self workoutWillEnd];
    [BTAchievement updateAchievementsWithWorkout:self.workout];
}

- (IBAction)settingsButtonPressed:(UIButton *)sender {
    [self updateWorkout];
    [self presentSettingsViewControllerWithPoint:sender.center];
}

- (IBAction)adjustTimesButtonPressed:(UIButton *)sender {
    self.addExerciseButton.hidden = YES;
    [self presentAdjustTimesViewControllerWithPoint:sender.center];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    [self presentAddExerciseViewController];
}   

- (IBAction)finishWorkoutButtonPressed:(UIButton *)sender {
    [self workoutWillEnd];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate workoutViewController:self didDismissWithResultWorkout:self.workout];
        [BTAchievement updateAchievementsWithWorkout:self.workout];
    }];
}

- (void)updateWorkout {
    [self updateWorkoutInterval];
    NSMutableDictionary <NSString *, NSNumber *> *dict = [[NSMutableDictionary alloc] init];
    self.workout.volume = 0;
    self.workout.numExercises = self.workout.exercises.count;
    self.workout.numSets = 0;
    for (BTExercise *exercise in self.workout.exercises) {
        if (dict[exercise.category]) dict[exercise.category] = [NSNumber numberWithInt:dict[exercise.category].intValue + 1];
        else                         dict[exercise.category] = [NSNumber numberWithInt:1];
        [exercise calculateOneRM];
        [exercise calculateVolume];
        self.workout.numSets += exercise.numberOfSets;
        self.workout.volume += exercise.volume;
    }
    self.workout.summary = @"0";
    if (self.workout.exercises.count > 0) {
        for (NSString *key in dict.allKeys)
            self.workout.summary = [NSString stringWithFormat:@"%@#%@ %@",self.workout.summary, dict[key], key];
        self.workout.summary = [self.workout.summary substringFromIndex:2];
    }
    self.workout.supersets = [NSKeyedArchiver archivedDataWithRootObject:self.tempSupersets];
    BOOL editName = YES;
    if (@available(iOS 11, *)) {
        if (self.settings.showSmartNames) {
            [self.workout calculateSmartName];
            self.nameTextField.text = (self.workout.smartName) ? self.workout.smartNickname : self.workout.name;
            editName = NO;
        }
    }
    if (editName && self.nameTextField.text.length > 0)
        self.workout.name = self.nameTextField.text;
    [self.context save:nil];
}

- (void)updateWorkoutInterval {
    if (self.settings.activeWorkoutStartDate) {
        NSTimeInterval timeInterval = [self.settings.activeWorkoutStartDate timeIntervalSinceDate:self.settings.activeWorkoutLastUpdate];
        if (timeInterval > 0) return;
        //if (self.workout.duration < 1) self.workout.date = [NSDate date];
        self.workout.duration += MIN(1800, -timeInterval+.5); //cap of 30 mins to prevent outrageous workout times
        self.settings.activeWorkoutStartDate = self.settings.activeWorkoutLastUpdate;
        [self.context save:nil];
    }
}

- (IBAction)deleteWorkoutButtonPressed:(UIButton *)sender {
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Delete Workout"
                                            message:@"Are you sure you want to delete this workout? You will lose all of your hard work! This action cannot be undone."
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteButton = [UIAlertAction actionWithTitle:@"Delete"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deleteWorkout];
        });
    }];
    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelButton];
    [alert addAction:deleteButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteWorkout {
    self.settings.activeWorkout = nil;
    self.settings.activeWorkoutStartDate = nil;
    self.settings.activeWorkoutLastUpdate = nil;
    [BTUser removeWorkoutFromTotals:self.workout];
    [self.context deleteObject:self.workout];
    [self.context save:nil];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:nil];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate workoutViewController:self didDismissWithResultWorkout:nil];
    }];
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workout.exercises.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)configureCell:(ExerciseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BTExercise *exercise = self.workout.exercises[indexPath.row];
    cell.supersetMode = [self supersetTypeForIndexPath:indexPath];
    cell.delegate = self;
    cell.color = self.exerciseTypeColors[exercise.category];
    [cell loadExercise:exercise];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"ExerciseTableViewCell" owner:self options:nil].firstObject;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (NSString *)supersetTypeForIndexPath:(NSIndexPath *)indexPath {
    NSArray <NSNumber *> *superset = [self supersetForIndexPath:indexPath];
    if (!superset) return SUPERSET_NONE;
    NSInteger index = [superset indexOfObject:[NSNumber numberWithInt:(int)indexPath.row]];
    if (index == 0) return SUPERSET_ABOVE;
    else if (index == superset.count-1) return SUPERSET_BELOW;
    return SUPERSET_BOTH;
}

- (NSMutableArray <NSNumber *> *)supersetForIndexPath:(NSIndexPath *)indexPath {
    for (NSMutableArray *arr in self.tempSupersets)
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

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.tableView];
    NSIndexPath *iP = [self.tableView indexPathForRowAtPoint:location];
    NSInteger destinationRow = (iP)? iP.row : -1;
    static UIView *snapshot = nil;
    static NSInteger sourceRow;
    static NSMutableArray <NSNumber *> *sourceSuperset = nil;
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            if (destinationRow >= 0) {
                sourceSuperset = [self supersetForIndexPath:[NSIndexPath indexPathForRow:destinationRow inSection:0]];
                if (!sourceSuperset) sourceSuperset = @[[NSNumber numberWithInteger:destinationRow]].mutableCopy;
                sourceRow = sourceSuperset.firstObject.integerValue;
                NSArray <ExerciseTableViewCell *> *cells = [self cellsForSuperset:sourceSuperset];
                snapshot = [self snapshotForCells:cells];
                __block CGPoint center =
                    CGPointMake(self.tableView.frame.size.width/2.0, cells.firstObject.frame.origin.y+snapshot.frame.size.height/2.0);
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    for (ExerciseTableViewCell *cell in cells) {
                        cell.alpha = 0.0;
                        cell.hidden = YES;
                    }
                }];
            } break;
        }
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            if (destinationRow >= 0 && [self.tableView.indexPathsForVisibleRows containsObject:
                                            [NSIndexPath indexPathForRow:destinationRow inSection:0]]) {
                if (destinationRow > sourceRow) { //moving down (to higher indexs)
                    NSInteger tempDestinationRow = destinationRow+sourceSuperset.count-1;
                    NSMutableArray <NSNumber *> *destinationSuperset =
                        [self supersetForIndexPath:[NSIndexPath indexPathForRow:tempDestinationRow inSection:0]];
                    if (!destinationSuperset) destinationSuperset = @[[NSNumber numberWithInteger:destinationRow]].mutableCopy;
                    BOOL isPastDestinationSuperset = !destinationSuperset || destinationRow-sourceRow >= destinationSuperset.count;
                    if (isPastDestinationSuperset && tempDestinationRow < self.workout.exercises.count) {
                        NSMutableOrderedSet *tempExercises = self.workout.exercises.mutableCopy;
                        for (int i = 0; i < destinationSuperset.count; i++) {
                            BTExercise *tempExercise = [tempExercises objectAtIndex:sourceRow+sourceSuperset.count+i];
                            [tempExercises removeObjectAtIndex:sourceRow+sourceSuperset.count+i];
                            [tempExercises insertObject:tempExercise atIndex:sourceRow+i];
                            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:sourceRow+sourceSuperset.count+i inSection:0]
                                                   toIndexPath:[NSIndexPath indexPathForRow:sourceRow+i inSection:0]];
                        }
                        self.workout.exercises = tempExercises;
                        NSInteger sourceIndex = [self.tempSupersets indexOfObject:sourceSuperset];
                        NSInteger destinationIndex = [self.tempSupersets indexOfObject:destinationSuperset];
                        for (int i = 0; i < sourceSuperset.count; i++) {
                            sourceSuperset[i] = [NSNumber numberWithInteger:sourceSuperset[i].integerValue+destinationSuperset.count];
                            if (sourceSuperset.count > 1)
                                self.tempSupersets[sourceIndex][i] = sourceSuperset[i];
                        }
                        for (int i = 0; i < destinationSuperset.count; i++) {
                            if (destinationSuperset.count > 1)
                                self.tempSupersets[destinationIndex][i] =
                                    [NSNumber numberWithInteger:destinationSuperset[i].integerValue-sourceSuperset.count];
                        }
                        if (sourceSuperset.count > 1 && destinationSuperset.count > 1)
                            [self.tempSupersets exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
                        sourceRow = destinationRow;
                    }
                }
                else if (sourceRow > destinationRow) { //moving up (to lower indexs)
                    NSMutableArray <NSNumber *> *destinationSuperset =
                        [self supersetForIndexPath:[NSIndexPath indexPathForRow:destinationRow inSection:0]];
                    if (!destinationSuperset) destinationSuperset = @[[NSNumber numberWithInteger:destinationRow]].mutableCopy;
                    BOOL isPastDestinationSuperset = !destinationSuperset || sourceRow-destinationRow >= destinationSuperset.count;
                    if (isPastDestinationSuperset) {
                        NSMutableOrderedSet *tempExercises = self.workout.exercises.mutableCopy;
                        for (int i = 0; i < sourceSuperset.count; i++) {
                            BTExercise *tempExercise = [tempExercises objectAtIndex:sourceRow+i];
                            [tempExercises removeObjectAtIndex:sourceRow+i];
                            [tempExercises insertObject:tempExercise atIndex:destinationRow+i];
                            [self.tableView moveRowAtIndexPath:[NSIndexPath indexPathForRow:sourceRow+i inSection:0]
                                                   toIndexPath:[NSIndexPath indexPathForRow:destinationRow+i inSection:0]];
                        }
                        self.workout.exercises = tempExercises;
                        NSInteger sourceIndex = [self.tempSupersets indexOfObject:sourceSuperset];
                        NSInteger destinationIndex = [self.tempSupersets indexOfObject:destinationSuperset];
                        for (int i = 0; i < sourceSuperset.count; i++) {
                            sourceSuperset[i] = [NSNumber numberWithInteger:sourceSuperset[i].integerValue-destinationSuperset.count];
                            if (sourceSuperset.count > 1)
                                self.tempSupersets[sourceIndex][i] = sourceSuperset[i];
                        }
                        for (int i = 0; i < destinationSuperset.count; i++) {
                            if (destinationSuperset.count > 1)
                                self.tempSupersets[destinationIndex][i] =
                                    [NSNumber numberWithInteger:destinationSuperset[i].integerValue+sourceSuperset.count];
                        }
                        if (sourceSuperset.count > 1 && destinationSuperset.count > 1)
                            [self.tempSupersets exchangeObjectAtIndex:sourceIndex withObjectAtIndex:destinationIndex];
                        sourceRow = destinationRow;
                    }
                }
                
            } break;
        }
        default: {
            NSArray <ExerciseTableViewCell *> *cells = [self cellsForSuperset:sourceSuperset];
            for (ExerciseTableViewCell *cell in cells) cell.alpha = 0;
            [UIView animateWithDuration:0.25 animations:^{
                snapshot.center = CGPointMake(self.tableView.frame.size.width/2.0, cells.firstObject.frame.origin.y+snapshot.frame.size.height/2.0);
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                for (ExerciseTableViewCell *cell in cells) cell.alpha = 1;
            } completion:^(BOOL finished) {
                for (ExerciseTableViewCell *cell in cells) cell.hidden = NO;
                sourceRow = -1;
                [snapshot removeFromSuperview];
            }]; break;
        }
    }
}

- (NSArray <ExerciseTableViewCell *> *)cellsForSuperset:(NSArray <NSNumber *> *)superset {
    NSMutableArray <ExerciseTableViewCell *> *cells = [NSMutableArray array];
    for (NSNumber *n in superset) {
        if ([self.tableView.indexPathsForVisibleRows containsObject:[NSIndexPath indexPathForRow:n.integerValue inSection:0]])
            [cells addObject:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:n.integerValue inSection:0]]];
        else {
            ExerciseTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:@"ExerciseTableViewCell" owner:self options:nil].firstObject;
            [self configureCell:cell atIndexPath:[NSIndexPath indexPathForRow:n.integerValue inSection:0]];
            [cells addObject:cell];
        }
    }
    return cells;
}

- (UIView *)snapshotForCells:(NSArray <ExerciseTableViewCell *> *)cells {
    UIView *cV = [[UIView alloc] initWithFrame:
        CGRectMake(0, 0, cells.firstObject.frame.size.width, cells.firstObject.frame.size.height*cells.count)];
    for (int i = 0; i < cells.count; i++) {
        ExerciseTableViewCell *cell = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:cells[i]]];
        cell.contentView.center = CGPointMake(cV.frame.size.width/2, cell.frame.size.height*(.5+i)-i);
        [cV addSubview:cell.contentView];
    }
    UIGraphicsBeginImageContextWithOptions(cV.bounds.size, NO, 0);
    [cV.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    return snapshot;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    //Even if the method is empty you should be seeing both rearrangement icon and animation.
}

#pragma mark - gesture handling

- (IBAction)pauseGestureActivated:(UITapGestureRecognizer *)sender {
    self.paused = !self.paused;
    if (!self.paused) {
        self.pauseView.alpha = 0;
        self.pauseView.userInteractionEnabled = NO;
    }
    else {
        self.pauseView.alpha = 1;
        self.pauseView.userInteractionEnabled = YES;
    }
}

#pragma mark - SWTableViewCell delegate

- (BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index
             direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion {
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    self.selectedIndexPaths = [NSMutableArray array];
    for (NSMutableArray *superset in self.tempSupersets) {
        for (NSNumber *num in superset) {
            if (num.integerValue == path.row) {
                for (NSNumber *num in superset)
                    if (num.integerValue != path.row)
                        [self.selectedIndexPaths addObject:[NSIndexPath indexPathForRow:num.integerValue inSection:0]];
            }   }   }
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[self resultIndexPathsFromDeleteExercisesActionWithExercises:@[((ExerciseTableViewCell *)cell).exercise]]
                          withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.selectedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self updateWorkout];
    return YES;
}

#pragma mark - addVC delegate

- (void)addExerciseViewController:(AddExerciseViewController *)addVC
        willDismissWithSelectedTypeIterationCombinations:(NSArray<NSArray *> *)selectedTypeIterationCombinations superset:(BOOL)superset {
    NSMutableArray <NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    if (!superset) {
        for (NSArray *tiCombo in selectedTypeIterationCombinations) {
            BTExercise *exercise = [BTExercise exerciseForExerciseType:tiCombo[0] iteration:tiCombo[1]];
            exercise.workout = self.workout;
            [self.workout addExercisesObject:exercise];
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.workout.exercises.count-1 inSection:0]];
        }
    }
    else {
        NSMutableArray <NSNumber *> *supersetArr = [[NSMutableArray alloc] init];
        for (NSArray *tiCombo in selectedTypeIterationCombinations) {
            BTExercise *exercise = [BTExercise exerciseForExerciseType:tiCombo[0] iteration:tiCombo[1]];
            exercise.workout = self.workout;
            [self.workout addExercisesObject:exercise];
            [supersetArr addObject:[NSNumber numberWithInt:(int)self.workout.exercises.count-1]];
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.workout.exercises.count-1 inSection:0]];
        }
        if (supersetArr.count > 1) [self.tempSupersets addObject:supersetArr];
    }
    [CATransaction begin];
    [CATransaction setCompletionBlock: ^{
        [self.tableView reloadData];
    }];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    [self.tableView endUpdates];
    [CATransaction commit];
    [self updateWorkout];
}

#pragma mark - exerciseVC delegate

- (void)exerciseViewController:(ExerciseViewController *)exerciseVC
                                    didRequestSaveWithEditedExercises:(NSArray<BTExercise *> *)exercises
                                                     deletedExercises:(NSArray<BTExercise *> *)deleted
                                                             animated:(BOOL)animated {
    if (animated) {
        NSArray *deletedIndexPaths = [self resultIndexPathsFromDeleteExercisesActionWithExercises:deleted];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadRowsAtIndexPaths:self.selectedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    [self updateWorkout];
}

- (void)exerciseViewDidAddSet:(ExerciseView *)exerciseView withResultExercise:(BTExercise *)exercise {
    self.settings.activeWorkoutLastUpdate = [NSDate date];
    if (!self.settings.activeWorkoutStartDate)
        self.settings.activeWorkoutStartDate = [NSDate date];
}

- (NSArray <NSIndexPath *> *)resultIndexPathsFromDeleteExercisesActionWithExercises:(NSArray <BTExercise *> *)deleted {
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
    }   }   }
    for (NSInteger i = self.tempSupersets.count-1; i >= 0; i--)
        if (self.tempSupersets[i].count <= 1) [self.tempSupersets removeObjectAtIndex:i];
    for (BTExercise *exercise in deleted) {
        [self.workout removeExercisesObject:exercise];
        [self.context deleteObject:exercise];
    }
    [self updateWorkout];
    return deletedIndexPaths;
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (@available(iOS 11, *)) {
        if(self.settings.showSmartNames) {
            [self presentEditSmartNamesViewController];
            return NO;
    }    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameTextField resignFirstResponder];
    return YES;
}

#pragma mark - settingsVC delegate

- (void)WorkoutSettingsViewControllerWillDismiss:(WorkoutSettingsViewController *)wsVC {
    self.addExerciseButton.hidden = NO;
}

#pragma mark - adjustTimesVC delegate

- (void)adjustTimesViewControllerWillDismiss:(AdjustTimesViewController *)adjustTimesVC {
    [self updateWorkout];
    self.addExerciseButton.hidden = NO;
}

#pragma mark - view handling

- (void)presentAddExerciseViewController {
    AddExerciseViewController *addVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ae"];
    addVC.delegate = self;
    addVC.context = self.context;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:addVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1-CGColorGetComponents([UIColor BTModalViewBackgroundColor].CGColor)[3];
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    addVC.transitioningDelegate = self.animator;
    addVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:addVC animated:YES completion:nil];
}

- (void)presentExerciseViewControllerWithExercises: (NSArray<BTExercise *> *)exercises {
    ExerciseViewController *eVC = [self.storyboard instantiateViewControllerWithIdentifier:@"e"];
    eVC.delegate = self;
    eVC.exercises = exercises;
    eVC.settings = self.settings;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:eVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1-CGColorGetComponents([UIColor BTModalViewBackgroundColor].CGColor)[3];
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.75;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    eVC.transitioningDelegate = self.animator;
    eVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:eVC animated:YES completion:nil];
}

- (void)presentSettingsViewControllerWithPoint:(CGPoint)point {
    WorkoutSettingsViewController *wseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"wse"];
    wseVC.delegate = self;
    wseVC.point = point;
    wseVC.context = self.context;
    wseVC.settings = self.settings;
    wseVC.workout = self.workout;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:wseVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    wseVC.transitioningDelegate = self.animator;
    wseVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:wseVC animated:YES completion:nil];
}

- (void)presentAdjustTimesViewControllerWithPoint:(CGPoint)point {
    AdjustTimesViewController *atVC = [self.storyboard instantiateViewControllerWithIdentifier:@"at"];
    atVC.delegate = self;
    atVC.point = point;
    atVC.context = self.context;
    atVC.workout = self.workout;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:atVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1.0;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    atVC.transitioningDelegate = self.animator;
    atVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:atVC animated:YES completion:nil];
}

- (void)presentEditSmartNamesViewController {
    EditSmartNamesViewController *esnVC = [[EditSmartNamesViewController alloc] initWithNibName:@"EditSmartNamesViewController"
                                                                                         bundle:[NSBundle mainBundle]];
    esnVC.context = self.context;
    esnVC.settings = self.settings;
    esnVC.selectedSmartName = self.workout.smartName;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:esnVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    esnVC.transitioningDelegate = self.animator;
    esnVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:esnVC animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
