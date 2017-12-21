//
//  IterationSelectionViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/5/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "IterationSelectionViewController.h"
#import "BTExerciseType+CoreDataClass.h"
#import "IterationTableViewCell.h"

@interface IterationSelectionViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containingView;

@property (nonatomic) NSArray <NSString *> *tempIerations;

@end

@implementation IterationSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempIerations = [NSKeyedUnarchiver unarchiveObjectWithData:self.exerciseType.iterations];
    self.scrollView.delegate = self;
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:45+50*(self.tempIerations.count+1)];
    [self.view addConstraint:constraint];
    self.backgroundView.backgroundColor = [UIColor BTModalViewBackgroundColor];
    self.tableView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor BTTableViewSeparatorColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ACell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"IterationTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"Cell"];
}

- (void)viewDidLayoutSubviews {
    self.tableView.layer.cornerRadius = 16;
    self.tableView.clipsToBounds = YES;
    self.containingView.alpha = 0.0;
    self.backgroundView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tempIerations.count == 0) {
        [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate iterationSelectionVCDidDismiss:self];
        }];
    }
    else [self animateIn];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
    [self animateOut];
}

- (IBAction)tapGesture2:(UITapGestureRecognizer *)sender {
    [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
    [self animateOut];
}

- (IBAction)tapGesture3:(UITapGestureRecognizer *)sender {
    [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
    [self animateOut];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tempIerations.count+2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return 45;
    return 50;
}

- (void)configureIterationCell:(IterationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) [cell loadName:self.exerciseType.name iteration:nil];
    else [cell loadName:self.exerciseType.name iteration:self.tempIerations[indexPath.row-2]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (self.color) cell.backgroundColor = self.color;
        else cell.backgroundColor = [UIColor BTPrimaryColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
        label.text = [NSString stringWithFormat:@"Select a Variation"];
        label.backgroundColor = [UIColor clearColor];
        [cell addSubview:label];
        return cell;
    }
    IterationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureIterationCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - tableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        if (indexPath.row == 1) [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
        else [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:self.tempIerations[indexPath.row-2]];
        [self animateOut];
    }
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
        [self.delegate iterationSelectionVC:self willDismissWithSelectedIteration:@""];
        [self animateOut];
        [UIView animateWithDuration:.75 delay:.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            if (scrollView.contentOffset.y >= 0)
                scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y-scrollView.frame.size.height);
            else scrollView.center = CGPointMake(scrollView.center.x, scrollView.center.y+scrollView.frame.size.height);
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - animation

- (void)animateIn {
    self.containingView.alpha = 1.0;
    self.backgroundView.alpha = 0.0;
    self.tableView.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
    self.tableView.alpha = 0.5;
    CGPoint endPoint = self.tableView.center;
    self.tableView.center = CGPointMake(-self.containingView.frame.origin.x+self.originPoint.x,
                                        -self.containingView.frame.origin.y+self.originPoint.y);
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.tableView.transform = CGAffineTransformIdentity;
        self.tableView.center = endPoint;
        self.tableView.alpha = 0.994; //prevents shadow
        self.backgroundView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)animateOut {
    [UIView animateWithDuration:.15 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        self.tableView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate iterationSelectionVCDidDismiss:self];
        }];
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [UIColor statusBarStyle];
}

@end
