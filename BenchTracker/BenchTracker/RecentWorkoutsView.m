//
//  RecentWorkoutsView.m
//  BenchTracker
//
//  Created by Chappy Asel on 2/24/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import "RecentWorkoutsView.h"
#import "BTExerciseType+CoreDataClass.h"
#import "BTAnalyticsPieChart.h"

@interface RecentWorkoutsView()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noInstancesLabel;
@property (weak, nonatomic) IBOutlet UIView *pieChartContainerView;
@property (nonatomic) BTAnalyticsPieChart *pieChart;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSDictionary<NSString *, NSNumber *> *data;
@property NSArray<NSString *> *sortedKeys;

@end

@implementation RecentWorkoutsView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)loadWithExerciseType:(BTExerciseType *)exerciseType iteration:(NSString *)iteration {
    if (self.pieChart) [self.pieChart removeFromSuperview];
    self.data = [exerciseType recentSmartNameSplitsForIteration:iteration];
    self.sortedKeys = [[self.data allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    self.pieChart = [[BTAnalyticsPieChart alloc] initWithFrame:CGRectMake(0, 0, 130, 130)
                                                         items:[BTAnalyticsPieChart pieDataForDictionary:self.data]];
    [self.pieChartContainerView addSubview:self.pieChart];
    [self.tableView reloadData];
}

- (void)strokeChart {
    self.pieChart.showOnlyValues = YES;
    [self.pieChart strokeChart];
}

#pragma mark - tableView delegate / dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.noInstancesLabel.alpha = (self.data.count == 0);
    self.tableView.alpha = (self.data.count > 0);
    self.pieChartContainerView.alpha = (self.data.count > 0);
    self.tableView.contentInset = UIEdgeInsetsMake((6-self.data.count)*27.5/2.0, 0, 0, 0);
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 27.5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    }
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithString:
        [NSString stringWithFormat:@"%@ %@", self.data[self.sortedKeys[indexPath.row]], self.sortedKeys[indexPath.row]]];
    [s setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13 weight:UIFontWeightHeavy]}
                range:NSMakeRange(0, [self.data[self.sortedKeys[indexPath.row]] stringValue].length)];
    cell.textLabel.attributedText = s;
    return cell;
}

@end
