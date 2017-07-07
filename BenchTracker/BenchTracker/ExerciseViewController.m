//
//  ExerciseViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/28/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseViewController.h"
#import "ExerciseView.h"
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"

@interface ExerciseViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@property (nonatomic) NSMutableArray<ExerciseView *> *exerciseViews;

@end

@implementation ExerciseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.doneButton.layer.cornerRadius = 12;
    self.doneButton.clipsToBounds = YES;
    self.exerciseViews = [[NSMutableArray alloc] init];
    int h = 185;
    NSDictionary *exerciseTypeColors;
    if (self.settings) exerciseTypeColors = [NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors];
    for (BTExercise *exercise in self.exercises) {
        ExerciseView *view = [[NSBundle mainBundle] loadNibNamed:@"ExerciseView" owner:self options:nil].firstObject;
        view.color = exerciseTypeColors[exercise.category];
        [view loadExercise:exercise];
        [self.exerciseViews addObject:view];
        [self.contentView addSubview:view];
        view.center = CGPointMake(self.contentView.frame.size.width*.5, h);
        h += 290;
    }
    if (self.exercises.count < 3) {
        if (self.exercises.count == 1) self.exerciseViews[0].center = CGPointMake(self.contentView.frame.size.width*.5,
                                                                                 (self.view.frame.size.height-40-50)*.5);
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:self.view.frame.size.height+1]];
    }
    else {
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:h-20]];
    }
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    NSMutableArray *dArr = [[NSMutableArray alloc] init];
    NSMutableArray *eArr = [[NSMutableArray alloc] init];
    for (ExerciseView *view in self.exerciseViews) {
        if (!view.isDeleted) [eArr addObject:[view getExercise]];
        else                 [dArr addObject:[view getExercise]];
    }
    [self.delegate exerciseViewController:self willDismissWithEditedExercises:eArr deletedExercises:dArr];
    [self dismissViewControllerAnimated:YES completion:^{
                                 
    }];
}

#pragma mark - scrollView delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExerciseViewScroll" object:nil];
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
