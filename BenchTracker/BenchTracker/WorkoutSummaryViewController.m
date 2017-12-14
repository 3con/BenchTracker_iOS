//
//  WorkoutSummaryViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 12/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "WorkoutSummaryViewController.h"
#import "BTWorkout+CoreDataClass.h"
#import "WorkoutSummaryTableViewCell.h"
#import "WorkoutMilestone.h"
#import "BTSettings+CoreDataClass.h"

@interface WorkoutSummaryViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneButtonWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneButtonCenterConstraint;
@property (weak, nonatomic) IBOutlet UIButton *secondaryButton;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *headerLabels;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noMilestonesLabel;
@property (nonatomic) NSArray<WorkoutMilestone *> *milestones;

@end

@implementation WorkoutSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [BTSettings sharedInstance];
    self.noMilestonesLabel.alpha = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 90, 0);
    self.contentView.backgroundColor = [UIColor BTVibrantColors][0];
    self.contentView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
    self.doneButton.alpha = 0.0;
    self.secondaryButton.alpha = 0.0;
    self.secondaryButton.titleLabel.numberOfLines = 2;
    self.secondaryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.secondaryButton.backgroundColor = [UIColor BTButtonSecondaryColor];
    [self setSecondaryButtonHidden:YES];
    [self loadWorkout];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self animateIn];
    [self performSelector:@selector(animateHeaderLabels) withObject:nil afterDelay:.3];
    [self performSelector:@selector(animateCells) withObject:nil afterDelay:.7];
}

- (void)animateHeaderLabels {
    for (int i = 1; i <= 12; i++)
        [self performSelector:@selector(loadHeaderLabelsWithRatio:) withObject:[NSNumber numberWithFloat:i/12.0] afterDelay:
         [@[@0, @.04, @.1, @.17, @.25, @.34, @.44, @.55, @.67, @.81, @.98, @1.18, @1.48][i] floatValue]];
}

- (void)animateCells {
    for (int i = 0; i < self.tableView.visibleCells.count; i++)
        [self.tableView.visibleCells[i] performSelector:@selector(animateIn) withObject:nil afterDelay:.2*i];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    self.doneButton.hidden = YES;
    self.secondaryButton.hidden = YES;
    [self.delegate workoutSummaryViewControllerWillDismiss:self];
    [self animateOutWithAcheivementShowRequest:NO];
}

- (IBAction)secondaryButtonPressed:(UIButton *)sender {
    self.doneButton.hidden = YES;
    self.secondaryButton.hidden = YES;
    [self.delegate workoutSummaryViewControllerWillDismiss:self];
    [self animateOutWithAcheivementShowRequest:YES];
}

- (void)setSecondaryButtonHidden:(BOOL)hidden {
    self.secondaryButton.hidden = hidden;
    self.doneButtonWidthConstraint.constant = (hidden)? 180 : 140;
    self.doneButtonCenterConstraint.constant = (hidden)? 0 : 80;
}

- (void)loadWorkout {
    self.titleLabel.text = @[@"Good Work!", @"Great Job!", @"Great Workout!", @"Massive Gains!", @"Way To Go!",
                        @"Excellent Work!", @"Good One!", @"Nice Work!", @"🏋️ Gains!", @"💪 Gains!"][arc4random()%10];
    self.milestones = [WorkoutMilestone milestonesForWorkout:self.workout];
    [self loadHeaderLabelsWithRatio:@0];
    for (WorkoutMilestone *milestone in self.milestones)
        if (milestone.type == WorkoutMilestoneTypeAchievement)
            [self setSecondaryButtonHidden:NO];
    [self.tableView reloadData];
}

- (void)loadHeaderLabelsWithRatio:(NSNumber *)ratio { //0-1
    self.headerLabels[0].text = [NSString stringWithFormat:@"%.0f", self.workout.numSets*ratio.floatValue];
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:
                                    [NSString stringWithFormat:@"%.0f", self.workout.volume/1000*ratio.floatValue]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"k %@", self.settings.weightSuffix]
                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11 weight:UIFontWeightMedium]}]];
    self.headerLabels[1].attributedText = s;
    s = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat:@"%.0f", self.workout.duration/60*ratio.floatValue]];
    [s appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" min"]
                                                              attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11 weight:UIFontWeightMedium]}]];
    self.headerLabels[2].attributedText = s;
}

#pragma mark - tableView delegate / dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.noMilestonesLabel.alpha = !self.milestones.count;
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WorkoutSummaryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) cell = [[NSBundle mainBundle] loadNibNamed:@"WorkoutSummaryTableViewCell" owner:self options:nil].firstObject;
    [cell loadWithMilestone:(self.milestones.count && self.milestones.count-1 >= indexPath.row) ? self.milestones[indexPath.row] : nil];
    return cell;
}

#pragma mark - scrollView delegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
    bool neglegable = fabs(velocity.y) < 0.2;
    float offset = fabs(scrollView.contentOffset.y);
    bool offsetPositive = scrollView.contentOffset.y >= 0;
    bool velocityPositive = velocity.y >= 0;
    if (neglegable && offset < 60.0) { } //no dismiss
    else if (!neglegable && (offsetPositive != velocityPositive)) { } //no dismiss
    else { //dismiss
        [self animateOutWithAcheivementShowRequest:NO];
        [self.delegate workoutSummaryViewControllerWillDismiss:self];
        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (scrollView.contentOffset.y >= 0)
                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - animation

- (void)animateIn {
    self.backgroundView.alpha = 0.0;
    self.contentView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.contentView.alpha = 0.5;
    //self.contentView.center = self.point;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.center = CGPointMake(self.view.center.x, self.view.center.y-35);
        self.contentView.transform = CGAffineTransformIdentity;
        self.contentView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
        self.doneButton.alpha = 1.0;
        self.secondaryButton.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOutWithAcheivementShowRequest:(BOOL)showRequest {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.contentView.alpha = 0.0;
        self.doneButton.alpha = 0.0;
        self.secondaryButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            if(showRequest) [self.delegate workoutSummaryViewControllerDidDismissWithAcheievementShowRequest:self];
        }];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
