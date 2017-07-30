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
#import "BTPDFGenerator.h"
#import "MMQRCodeMakerUtil.h"
#import "QRDisplayViewController.h"
#import "BTSettings+CoreDataClass.h"
#import "BT1RMCalculator.h"

@interface WorkoutViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UIButton *finishWorkoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteWorkoutButton;

@property (weak, nonatomic) IBOutlet UIView *pauseView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addExerciseButton;

@property (nonatomic) ZFModalTransitionAnimator *animator;
@property BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;
@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (nonatomic) NSMutableArray <NSMutableArray <NSNumber *> *> *tempSupersets;

@property (nonatomic) NSMutableArray <BTExercise *> *selectedExercises;
@property (nonatomic) NSMutableArray <NSIndexPath *> *selectedIndexPaths;

@property (nonatomic) BOOL paused;
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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(2.5, 0, 92.5, 0);
    self.addExerciseButton.layer.cornerRadius = 12;
    self.addExerciseButton.clipsToBounds = YES;
    self.nameTextField.delegate = self;
    self.finishWorkoutButton.layer.cornerRadius = 12;
    self.finishWorkoutButton.clipsToBounds = YES;
    self.deleteWorkoutButton.layer.cornerRadius = 12.5;
    self.deleteWorkoutButton.clipsToBounds = YES;
    self.workoutManager = [BTWorkoutManager sharedInstance];
    if (!self.workout) self.workout = [self.workoutManager createWorkout];
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.workout.name
        attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont italicSystemFontOfSize:22]}];
    self.tempSupersets = [NSKeyedUnarchiver unarchiveObjectWithData:self.workout.supersets];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.addExerciseButton.alpha = 1;
    if (self.settings.disableSleep) [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)handleEnteredBackground:(id)sender {
    [self updateWorkout];
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
    [self updateWorkout];
    [self.delegate workoutViewController:self willDismissWithResultWorkout:self.workout];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)updateWorkout {
    if (self.startDate) {
        NSTimeInterval timeInterval = [self.startDate timeIntervalSinceNow];
        self.workout.duration += -timeInterval+1;
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
        exercise.oneRM = 0;
        for (NSString *set in [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets]) {
            NSArray <NSString *> *split = [set componentsSeparatedByString:@" "];
            if ([exercise.style isEqualToString:STYLE_REPSWEIGHT]) {
                self.workout.volume += split[0].floatValue*split[1].floatValue;
                exercise.oneRM = MAX(exercise.oneRM, [BT1RMCalculator equivilentForReps:split[0].intValue weight:split[1].floatValue]);
            }
            else if ([exercise.style isEqualToString:STYLE_REPS])
                exercise.oneRM = MAX(exercise.oneRM, split[0].intValue);
            else if ([exercise.style isEqualToString:STYLE_TIME])
                exercise.oneRM = MAX(exercise.oneRM, split[1].intValue);
            else if ([exercise.style isEqualToString:STYLE_TIMEWEIGHT])
                exercise.oneRM = MAX(exercise.oneRM, split[2].floatValue);
            self.workout.numSets ++;
        }
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
    [self.workoutManager deleteWorkout:self.workout];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExerciseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BTExercise *exercise = self.workout.exercises[indexPath.row];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"ExerciseTableViewCell" owner:self options:nil].firstObject;
    cell.supersetMode = [self supersetTypeForIndexPath:indexPath];
    cell.delegate = self;
    cell.color = self.exerciseTypeColors[exercise.category];
    [cell loadExercise:exercise];
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

- (NSArray <NSNumber *> *)supersetForIndexPath:(NSIndexPath *)indexPath {
    for (NSArray *arr in self.tempSupersets)
        if([arr containsObject:[NSNumber numberWithInt:(int)indexPath.row]]) return arr;
    return nil;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
    [self.tableView deleteRowsAtIndexPaths:[self indexPathsForDeletedExercises:@[((ExerciseTableViewCell *)cell).exercise]]
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

- (void)exerciseViewController:(ExerciseViewController *)exerciseVC willDismissWithEditedExercises:(NSArray<BTExercise *> *)exercises
                                                                                  deletedExercises:(NSArray<BTExercise *> *)deleted {
    NSArray *deletedIndexPaths = [self indexPathsForDeletedExercises:deleted];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:self.selectedIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self updateWorkout];
}

- (NSArray <NSIndexPath *> *)indexPathsForDeletedExercises:(NSArray <BTExercise *> *)deleted {
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
    NSString *jsonString = [self.workoutManager jsonForWorkout:self.workout];
    NSString *jsonString2 = [self.workoutManager jsonForTemplateWorkout:self.workout];
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
