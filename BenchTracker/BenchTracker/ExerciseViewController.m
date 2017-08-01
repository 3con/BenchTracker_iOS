//
//  ExerciseViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseViewController.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "EquivalencyChartViewController.h"
#import "ZFModalTransitionAnimator.h"

@interface ExerciseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic) NSMutableArray<ExerciseView *> *exerciseViews;

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BOOL firstShow;

@end

@implementation ExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.firstShow = YES;
    self.doneButton.backgroundColor = [UIColor BTButtonPrimaryColor];
    self.scrollView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.firstShow) {
        self.firstShow = NO;
        self.doneButton.layer.cornerRadius = 12;
        self.doneButton.clipsToBounds = YES;
        self.exerciseViews = [[NSMutableArray alloc] init];
        int h = 185;
        NSDictionary *exerciseTypeColors;
        if (self.settings) exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
        for (BTExercise *exercise in self.exercises) {
            ExerciseView *view = [[NSBundle mainBundle] loadNibNamed:@"ExerciseView" owner:self options:nil].firstObject;
            view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, 260);
            view.delegate = self;
            view.settings = self.settings;
            view.color = exerciseTypeColors[exercise.category];
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
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleEnterBackground:(id)sender {
    [self saveExercisesAnimated:NO];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self saveExercisesAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
                                 
    }];
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

- (void)exerciseViewRequestedShowTable:(ExerciseView *)exerciseView {
    [self presentEquivalencyChartViewController];
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExerciseViewScroll" object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - view handling

- (void)presentEquivalencyChartViewController {
    EquivalencyChartViewController *ecVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ec"];
    ecVC.settings = self.settings;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:ecVC];
    self.animator.dragable = NO;
    self.animator.bounces = YES;
    self.animator.behindViewAlpha = 0.8;
    self.animator.behindViewScale = 0.92;
    self.animator.transitionDuration = 0.5;
    self.animator.direction = ZFModalTransitonDirectionBottom;
    ecVC.transitioningDelegate = self.animator;
    ecVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ecVC animated:YES completion:nil];
}

@end
