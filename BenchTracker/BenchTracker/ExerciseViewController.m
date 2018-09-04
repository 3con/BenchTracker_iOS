//
//  ExerciseViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseViewController.h"
#import "BTExercise+CoreDataClass.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "EquivalencyChartViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "ADExercisesDetailViewController.h"

@interface ExerciseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) id previewingContext;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic) NSDictionary *exerciseTypeColors;

@property (nonatomic) NSMutableArray<ExerciseView *> *exerciseViews;

@property (nonatomic) NSInteger activeExerciseViewIndex;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BOOL firstShow;

@end

@implementation ExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstShow = YES;
    self.doneButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    [self.doneButton setTitleColor: [UIColor BTButtonTextPrimaryColor] forState:UIControlStateNormal];
    self.scrollView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [Log event:@"ExerciseVC: Loaded" properties:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.firstShow) {
        self.firstShow = NO;
        self.doneButton.layer.cornerRadius = 12;
        self.doneButton.clipsToBounds = YES;
        self.exerciseViews = [[NSMutableArray alloc] init];
        int h = 185;
        if (self.settings) self.exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
        for (BTExercise *exercise in self.exercises) {
            ExerciseView *view = [[NSBundle mainBundle] loadNibNamed:@"ExerciseView" owner:self options:nil].firstObject;
            view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 260);
            view.delegate = self;
            view.settings = self.settings;
            view.color = self.exerciseTypeColors[exercise.category];
            [view loadExercise:exercise];
            [self.exerciseViews addObject:view];
            [self.contentView addSubview:view];
            view.center = CGPointMake(self.contentView.frame.size.width*.5, h);
            h += 290;
        }
        if (self.exercises.count == 1) self.exerciseViews[0].center =
            CGPointMake(self.contentView.frame.size.width*.5, (self.view.frame.size.height-40-50)*.5);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:MAX(self.view.frame.size.height+1, h+101)]]; //Keyboard: 226px
    }
    else for (ExerciseView *view in self.exerciseViews) [view reloadData];
    [Log event:@"ExerciseVC: Presentation" properties:@{@"Count": @(self.exercises.count)}];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    for (ExerciseView *view in self.exerciseViews) {
        CGRect frame = view.frame;
        frame.size.height = 260;
        view.frame = frame;
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location {
    if ([self.presentedViewController isKindOfClass:[EquivalencyChartViewController class]] ||
        [self.presentedViewController isKindOfClass:[ADExercisesDetailViewController class]]) return nil;
    for (ExerciseView *view in self.exerciseViews) {
        CGPoint point = [view.contentView convertPoint:location fromView:self.view];
        if (CGRectContainsPoint(view.previousExerciseButton.frame, point)) {
            ADExercisesDetailViewController *adedVC = [[NSBundle mainBundle] loadNibNamed:@"ADExercisesDetailViewController"
                                                                                    owner:self options:nil].firstObject;
            adedVC.settings = self.settings;
            adedVC.color = [UIColor BTButtonSecondaryColor];
            adedVC.titleString = [view getExercise].name;
            adedVC.iteration = [view getExercise].iteration;
            previewingContext.sourceRect = [self.view convertRect:view.previousExerciseButton.frame fromView:view.contentView];
            return adedVC;
        }
        if (CGRectContainsPoint(view.tableShowButton.frame, point)) {
            EquivalencyChartViewController *ecVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ec"];
            ecVC.settings = self.settings;
            ecVC.exercise = [view getExercise];
            previewingContext.sourceRect = [self.view convertRect:view.tableShowButton.frame fromView:view.contentView];
            return ecVC;
        }
    }
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    [self presentViewController:viewControllerToCommit animated:YES completion:nil];
}

- (void)handleEnterBackground:(id)sender {
    [self saveExercisesAnimated:NO];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self saveExercisesAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveExercisesAnimated:(BOOL)animated {
    NSMutableArray *dArr = [[NSMutableArray alloc] init];
    NSMutableArray *eArr = [[NSMutableArray alloc] init];
    for (ExerciseView *view in self.exerciseViews) {
        if (!view.isDeleted) [eArr addObject:[view getExercise]];
        else                 [dArr addObject:[view getExercise]];
    }
    [self.delegate exerciseViewController:self didRequestSaveWithEditedExercises:eArr deletedExercises:dArr animated:animated];
}

#pragma mark - exerciseView delegate

- (void)exerciseViewDidAddSet:(ExerciseView *)exerciseView {
    [self.delegate exerciseViewDidAddSet:exerciseView withResultExercise:[exerciseView getExercise]];
}

- (void)exerciseViewRequestedEditIteration:(ExerciseView *)exerciseView withPoint:(CGPoint)point {
    self.activeExerciseViewIndex = [self.exerciseViews indexOfObject:exerciseView];
    CGPoint nP = CGPointMake(point.x+[exerciseView.superview convertPoint:exerciseView.frame.origin toView:nil].x,
                             point.y+[exerciseView.superview convertPoint:exerciseView.frame.origin toView:nil].y);
    [self presentIterationSelectionViewControllerWithExercise:[exerciseView getExercise] point:nP];
}

- (void)exerciseViewRequestedShowExerciseDetails:(ExerciseView *)exerciseView {
    for (ExerciseView *ev in self.exerciseViews) [ev getExercise];
    [self presentExerciseDetailViewControllerWithExerice:[exerciseView getExercise]];
}

- (void)exerciseViewRequestedShowTable:(ExerciseView *)exerciseView {
    for (ExerciseView *ev in self.exerciseViews) [ev getExercise];
    [self presentEquivalencyChartViewControllerWithExercise:[exerciseView getExercise]];
}

#pragma mark - iterationSelectionVC delegate

- (void)iterationSelectionVC:(IterationSelectionViewController *)iterationVC willDismissWithSelectedIteration:(NSString *)iteration {
    [self.exerciseViews[self.activeExerciseViewIndex] setIteration:iteration];
}

- (void)iterationSelectionVCDidDismiss:(IterationSelectionViewController *)iterationVC {
    
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExerciseViewScroll" object:nil];
}

#pragma mark - view handling

- (void)presentIterationSelectionViewControllerWithExercise:(BTExercise *)exercise point:(CGPoint)point {
    IterationSelectionViewController *isVC = [self.storyboard instantiateViewControllerWithIdentifier:@"is"];
    isVC.delegate = self;
    isVC.exerciseType = [BTExerciseType typeForExercise:exercise];
    isVC.originPoint = point;
    isVC.color = self.exerciseTypeColors[exercise.category];
    [self presentViewController:isVC withStyle:BTPresentationStyleNone];
}

- (void)presentExerciseDetailViewControllerWithExerice:(BTExercise *)exercise {
    ADExercisesDetailViewController *adedVC = [[NSBundle mainBundle] loadNibNamed:@"ADExercisesDetailViewController"
                                                                            owner:self options:nil].firstObject;
    adedVC.settings = self.settings;
    adedVC.color = [UIColor BTButtonSecondaryColor];
    adedVC.titleString = exercise.name;
    adedVC.iteration = exercise.iteration;
    [self presentViewController:adedVC withStyle:BTPresentationStyleFromBottom];
}

- (void)presentEquivalencyChartViewControllerWithExercise:(BTExercise *)exercise {
    EquivalencyChartViewController *ecVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ec"];
    ecVC.settings = self.settings;
    ecVC.exercise = exercise;
    [self presentViewController:ecVC withStyle:BTPresentationStyleFromBottom];
}

- (BOOL)isForceTouchAvailable {
    return [self.traitCollection respondsToSelector:@selector(forceTouchCapability)] &&
    self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext)
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    else if (self.previewingContext) {
        [self unregisterForPreviewingWithContext:self.previewingContext];
        self.previewingContext = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
