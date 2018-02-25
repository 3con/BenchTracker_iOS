//
//  BTViewMoreView.m
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "BTViewMoreView.h"
#import "SetProgressionsView.h"
#import "RecentWorkoutsView.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTExercise+CoreDataClass.h"

@interface BTViewMoreView()

@property (nonatomic) BOOL isShowingGraph1;
@property (weak, nonatomic) IBOutlet UIView *graph1ContainerView;
@property (nonatomic) SetProgressionsView *graphView1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hideGraph1Constraint;

@property (weak, nonatomic) IBOutlet UIView *graph2ContainerView;
@property (nonatomic) RecentWorkoutsView *graphView2;

@end

@implementation BTViewMoreView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.graphView1 = [[NSBundle mainBundle] loadNibNamed:@"SetProgressionsView" owner:self options:nil].firstObject;
    [self.graph1ContainerView addSubview:self.graphView1];
    self.graphView1.frame = self.graph1ContainerView.bounds;
    self.graphView1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.graphView2 = [[NSBundle mainBundle] loadNibNamed:@"RecentWorkoutsView" owner:self options:nil].firstObject;
    [self.graph2ContainerView addSubview:self.graphView2];
    self.graphView2.frame = self.graph2ContainerView.bounds;
    self.graphView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setColor:(UIColor *)color {
    for (UIView *view in self.subviews)
        view.backgroundColor = color;
}

- (void)setExerciseType:(BTExerciseType *)exerciseType {
    _exerciseType = exerciseType;
    self.isShowingGraph1 = [self.exerciseType.style isEqualToString:STYLE_REPSWEIGHT];
}

- (void)setIteration:(NSString *)iteration {
    _iteration = iteration;
    self.graph1ContainerView.alpha = self.isShowingGraph1;
    self.hideGraph1Constraint.active = !self.isShowingGraph1;
    if (self.isShowingGraph1)
        [self.graphView1 loadWithExerciseType:self.exerciseType iteration:iteration];
    [self.graphView2 loadWithExerciseType:self.exerciseType iteration:iteration];
    [self strokeCharts];
}

- (void)setExpanded:(BOOL)expanded {
    _expanded = expanded;
    if (expanded) [self strokeCharts];
}

- (float)preferredHeight {
    return (!self.expanded) ? 0 : (self.isShowingGraph1) ? 460 : 230;
}

#pragma mark - private methods

- (void)strokeCharts {
    [self.graphView1 strokeChart];
    [self.graphView2 strokeChart];
}

@end
