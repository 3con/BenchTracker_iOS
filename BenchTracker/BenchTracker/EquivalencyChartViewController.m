//
//  EquivalencyChartViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "EquivalencyChartViewController.h"
#import "ECTableViewCell.h"
#import "ECSideTableViewCell.h"
#import "AppDelegate.h"

#define SIZE_WIDTH  25
#define SIZE_HEIGHT 119 //10-600

@interface EquivalencyChartViewController ()
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic) NSManagedObjectContext *context;

@property (weak, nonatomic) IBOutlet SetCollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UITableView *sideTableView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic) NSMutableSet <UIScrollView *> *mainScrollViews;

@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation EquivalencyChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTSecondaryColor];
    self.view.backgroundColor = [UIColor BTPrimaryColor];
    self.context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    self.collectionView.display1RM = YES;
    self.collectionView.setDataSource = self;
    self.collectionView.sets = [NSKeyedUnarchiver unarchiveObjectWithData:self.exercise.sets];
    self.collectionView.settings = self.settings;
    self.mainScrollViews = [NSMutableSet set];
    for (UITableView *tableView in @[self.sideTableView, self.mainTableView]) {
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.allowsSelection = NO;
    }
    [self.mainTableView registerNib:[UINib nibWithNibName:@"ECTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self.sideTableView registerNib:[UINib nibWithNibName:@"ECSideTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    [self loadTopScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSArray <NSString *> *arr = (self.collectionView.sets.lastObject) ?
        [self.collectionView.sets.lastObject componentsSeparatedByString:@" "] : nil;
    self.selectedIndexPath = (arr) ? [NSIndexPath indexPathForRow:MIN(118, MAX(0, (arr[1].floatValue-7.5)/5.0))
                                                        inSection:MIN(24, MAX(0, arr[0].intValue-2))] : nil;
    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:0]
                              atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    [self scrollHorizontallyToOffset:CGPointMake(50.0*(self.selectedIndexPath.section+.5)-(self.view.frame.size.width-70)/2.0, 0)];
}

- (void)loadTopScrollView {
    for (int i = 0; i < SIZE_WIDTH-1; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50*i, 0, 50, 35)];
        label.backgroundColor = [UIColor BTPrimaryColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
        label.text = [NSString stringWithFormat:@"%d",i+2];
        [self.topScrollView addSubview:label];
    }
    self.topScrollView.contentSize = CGSizeMake(50*SIZE_WIDTH-1, 35);
    self.topScrollView.delegate = self;
    [self.mainScrollViews addObject:self.topScrollView];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    self.exercise.sets = [NSKeyedArchiver archivedDataWithRootObject:self.collectionView.sets];
    [self.context save:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SIZE_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.sideTableView) {
        ECSideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.titleLabel.text = [NSString stringWithFormat:@"%d %@",10+(int)indexPath.row*5,self.settings.weightSuffix];
        return cell;
    }
    ECTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectedSection = (self.selectedIndexPath && indexPath.row == self.selectedIndexPath.row) ?
        self.selectedIndexPath.section : -1;
    [cell loadWithWeight:indexPath.row*5+10 length:SIZE_WIDTH-1];
    cell.scrollView.contentOffset = self.mainScrollViews.allObjects.firstObject.contentOffset;
    cell.scrollView.delegate = self;
    [self.mainScrollViews addObject:cell.scrollView];
    return cell;
}

#pragma mark - tableView delegate

#pragma mark - setCollectionView dataSource

- (NSString *)setToAddForSetCollectionView:(SetCollectionView *)collectionView {
    return (self.selectedIndexPath) ?
        [NSString stringWithFormat:@"%ld %ld",self.selectedIndexPath.section+2, self.selectedIndexPath.row*5+10] : nil;
}

#pragma mark - tapGesture delegate

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.mainTableView];
    NSInteger oldRow = self.selectedIndexPath.row;
    self.selectedIndexPath = [NSIndexPath indexPathForRow:location.y/35.0 inSection:(self.topScrollView.contentOffset.x+location.x)/50.0];
    [self.mainTableView beginUpdates];
    [self.mainTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:oldRow inSection:0],
                                                 [NSIndexPath indexPathForRow:self.selectedIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
    [self.mainTableView endUpdates];
}

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainTableView || scrollView == self.sideTableView) {
        self.mainTableView.contentOffset = scrollView.contentOffset;
        self.sideTableView.contentOffset = scrollView.contentOffset;
    }
    else [self scrollHorizontallyToOffset:scrollView.contentOffset];
}

- (void)scrollHorizontallyToOffset:(CGPoint)offset {
    for (UIScrollView *sV in self.mainScrollViews)
        sV.contentOffset = offset;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
