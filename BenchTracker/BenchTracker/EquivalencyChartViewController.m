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

#define SIZE_WIDTH  25
#define SIZE_HEIGHT 118 //10-600

@interface EquivalencyChartViewController ()
@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UIScrollView *topScrollView;
@property (weak, nonatomic) IBOutlet UITableView *sideTableView;
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;

@property (nonatomic) NSMutableSet <UIScrollView *> *mainScrollViews;

@end

@implementation EquivalencyChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.view.backgroundColor = [UIColor BTSecondaryColor];
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
    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:7 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)loadTopScrollView {
    for (int i = 0; i < SIZE_WIDTH-1; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(60*i, 0, 60, 40)];
        label.backgroundColor = [UIColor BTSecondaryColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        label.text = [NSString stringWithFormat:@"%d",i+2];
        [self.topScrollView addSubview:label];
    }
    self.topScrollView.contentSize = CGSizeMake(60*SIZE_WIDTH-1, 40);
    self.topScrollView.delegate = self;
    [self.mainScrollViews addObject:self.topScrollView];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return SIZE_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.sideTableView) {
        ECSideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.titleLabel.text = [NSString stringWithFormat:@"%ld %@",10+indexPath.row*5,self.settings.weightSuffix];
        return cell;
    }
    ECTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell loadWithWeight:indexPath.row*5+10 length:SIZE_WIDTH-1];
    cell.scrollView.contentOffset = self.mainScrollViews.allObjects.firstObject.contentOffset;
    cell.scrollView.delegate = self;
    [self.mainScrollViews addObject:cell.scrollView];
    return cell;
}

#pragma mark - tableView delegate

#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainTableView || scrollView == self.sideTableView) {
        self.mainTableView.contentOffset = scrollView.contentOffset;
        self.sideTableView.contentOffset = scrollView.contentOffset;
    }
    else {
        for (UIScrollView *sV in self.mainScrollViews)
            sV.contentOffset = scrollView.contentOffset;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
