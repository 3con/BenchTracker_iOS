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
#import "ZFModalTransitionAnimator.h"
#import "ExerciseTableViewCell.h"
#import "PassTouchesView.h"
#import "BTPDFGenerator.h"
#import "MMQRCodeMakerUtil.h"
#import "QRDisplayViewController.h"
#import "BTSettings+CoreDataClass.h"
#import "BT1RMCalculator.h"
#import "Appirater.h"

@interface WorkoutViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

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
@property (nonatomic) NSDate *potentialStartDate;
@property (nonatomic) NSDate *startDate;

@end

@implementation WorkoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.finishWorkoutButton.backgroundColor = [UIColor BTSecondaryColor];
    self.addExerciseButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    self.deleteWorkoutButton.backgroundColor = [UIColor BTRedColor];
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
    if (!self.workout) {
        [Appirater userDidSignificantEvent:YES];
        self.workout = [BTWorkout workout];
    }
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.workout.name
        attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont italicSystemFontOfSize:22]}];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.addExerciseButton.alpha = 1;
    if (self.settings.disableSleep) [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.potentialStartDate = [NSDate date];
    self.settings.activeWorkout = self.workout;
    [self.context save:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleEnteredBackground:(id)sender {
    [self updateWorkout];
}

- (void)handleWillTerminate:(id)sender {
    self.settings.activeWorkout = nil;
    [self updateWorkout];
    [self.context save:nil];
}

- (IBAction)pdfButtonPressed:(id)sender {
    [self updateWorkout];
    self.startDate = nil;
    NSString *path = [BTPDFGenerator generatePDFWithWorkouts:@[self.workout]];
    /*
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [webView loadRequest:request];
    [self.view addSubview:webView];
     */
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    //printController.delegate = self;
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = self.workout.name;
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    printController.printInfo = printInfo;
    printController.printingItem = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path]];
    [printController presentAnimated:YES completionHandler:^(UIPrintInteractionController *printInteractionController, BOOL completed, NSError *error){
        if (!completed && error) NSLog(@"FAILED! due to error in domain %@ with error code %lu", error.domain, (long)error.code);
    }];
}

- (IBAction)qrButtonPressed:(UIButton *)sender {
    [self updateWorkout];
    [self presentQRDisplayViewControllerWithPoint:sender.center];
}

- (IBAction)addExerciseButtonPressed:(UIButton *)sender {
    if (!self.startDate) self.startDate = [NSDate date];
    [self presentAddExerciseViewController];
}   

- (IBAction)finishWorkoutButtonPressed:(UIButton *)sender {
    self.settings.activeWorkout = nil;
    [self updateWorkout];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)updateWorkout {
    if (self.startDate) {
        NSTimeInterval timeInterval = [self.startDate timeIntervalSinceNow];
        self.workout.duration += MIN(1200, -timeInterval+1); //cap of 20 mins to prevent outrageous workout times
        self.startDate = [NSDate date];
    }
    if (self.nameTextField.text.length > 0) self.workout.name = self.nameTextField.text;
    NSMutableDictionary <NSString *, NSNumber *> *dict = [[NSMutableDictionary alloc] init];
    self.workout.volume = 0;
    self.workout.numExercises = self.workout.exercises.count;
    self.workout.numSets = 0;
    for (BTExercise *exercise in self.workout.exercises) {
        if (dict[exercise.category]) dict[exercise.category] = [NSNumber numberWithInt:dict[exercise.category].intValue + 1];
        else                         dict[exercise.category] = [NSNumber numberWithInt:1];
        [exercise calculateOneRM];
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
    [self.context save:nil];
}

- (IBAction)deleteWorkoutButtonPressed:(UIButton *)sender {
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Delete Workout"
                                 message:@"Are you sure you want to delete this workout? You will lose all you hard work! This action cannot be undone."
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* deleteButton = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self deleteWorkout];
        });
    }];
    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelButton];
    [alert addAction:deleteButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteWorkout {
    self.settings.activeWorkout = nil;
    [self.context deleteObject:self.workout];
    [self.context save:nil];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:nil];
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
    if (self.potentialStartDate) {
        self.startDate = self.potentialStartDate;
        self.potentialStartDate = nil;
    }
    if (!self.startDate) self.startDate = [NSDate date];
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
    if (self.paused) {
        self.pauseView.alpha = 0;
        self.pauseView.userInteractionEnabled = NO;
        self.startDate = [NSDate date];
    }
    else {
        self.pauseView.alpha = 1;
        self.pauseView.userInteractionEnabled = YES;
        [self updateWorkout];
        self.startDate = nil;
    }
    self.paused = !self.paused;
}

#pragma mark - SWTableViewCell delegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
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
}

#pragma mark - addVC delegate

- (void)addExerciseViewController:(AddExerciseViewController *)addVC
        willDismissWithSelectedTypeIterationCombinations:(NSArray<NSArray *> *)selectedTypeIterationCombinations superset:(BOOL)superset {
    NSMutableArray <NSIndexPath *> *indexPaths = [[NSMutableArray alloc] init];
    if (!superset) {
        for (NSArray *tiCombo in selectedTypeIterationCombinations) {
            [self.workout addExercisesObject:[self exerciseForExerciseType:tiCombo[0] iteration:tiCombo[1]]];
            [indexPaths addObject:[NSIndexPath indexPathForRow:self.workout.exercises.count-1 inSection:0]];
        }
    }
    else {
        NSMutableArray <NSNumber *> *supersetArr = [[NSMutableArray alloc] init];
        for (NSArray *tiCombo in selectedTypeIterationCombinations) {
            [self.workout addExercisesObject:[self exerciseForExerciseType:tiCombo[0] iteration:tiCombo[1]]];
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
}

- (BTExercise *)exerciseForExerciseType: (BTExerciseType *)type iteration: (id)iteration {
    BTExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName:@"BTExercise" inManagedObjectContext:self.context];
    exercise.name = type.name;
    exercise.iteration = ([iteration isKindOfClass:[NSNull class]]) ? nil : iteration;
    exercise.category = type.category;
    exercise.style = type.style;
    exercise.oneRM = 0;
    exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:[[NSMutableArray alloc] init]];
    exercise.workout = self.workout;
    return exercise;
}

#pragma mark - exerciseVC delegate

- (void)exerciseViewController:(ExerciseViewController *)exerciseVC didRequestSaveWithEditedExercises:(NSArray<BTExercise *> *)exercises
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
    return deletedIndexPaths;
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.nameTextField resignFirstResponder];
    return YES;
}

#pragma mark - view handling

- (void)presentAddExerciseViewController {
    self.addExerciseButton.alpha = 0;
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
    eVC.delegate = self;
    eVC.exercises = exercises;
    eVC.settings = self.settings;
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

- (void)presentQRDisplayViewControllerWithPoint:(CGPoint)point {
    NSString *jsonString = [BTWorkout jsonForWorkout:self.workout];
    NSString *jsonString2 = [BTWorkout jsonForTemplateWorkout:self.workout];
    QRDisplayViewController *qVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qd"];
    qVC.image1 = [MMQRCodeMakerUtil qrImageWithContent:jsonString logoImage:nil qrColor:nil qrWidth:440];
    qVC.image2 = [MMQRCodeMakerUtil qrImageWithContent:jsonString2 logoImage:nil qrColor:nil qrWidth:440];
    qVC.point = point;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:qVC];
    self.animator.bounces = NO;
    self.animator.dragable = NO;
    self.animator.behindViewAlpha = 1;
    self.animator.behindViewScale = 1;
    self.animator.transitionDuration = 0;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    qVC.transitioningDelegate = self.animator;
    qVC.modalPresentationStyle = UIModalPresentationCustom;
    [self presentViewController:qVC animated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
