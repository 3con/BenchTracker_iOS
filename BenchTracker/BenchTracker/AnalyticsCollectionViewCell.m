//
//  AnalyticsCollectionViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsCollectionViewCell.h"
#import "PNChart.h"

@interface AnalyticsCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullListConstraint;

@property (weak, nonatomic) IBOutlet UIView *tableContainerView;

@property (nonatomic) UITableView *tableView;

@property (nonatomic) CGFloat tableViewHeight;

@end

@implementation AnalyticsCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.tableView = [[UITableView alloc] init];
    self.tableView.userInteractionEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableContainerView addSubview:self.tableView];
    self.seeMoreButton.userInteractionEnabled = NO;
}

- (void)setGraphView:(PNGenericChart *)graphView {
    [self.graphView removeFromSuperview];
    _graphView = graphView;
    self.graphView.userInteractionEnabled = NO;
    [self.graphContainerView addSubview:self.graphView];
    [(PNBarChart *)self.graphView strokeChart];
    self.noDataLabel.alpha = (self.graphView.tag == -1);
}

- (void)setGraphHeight:(CGFloat)graphHeight {
    self.fullListConstraint.active = graphHeight == 0;
    _graphHeight = graphHeight;
    self.graphHeightConstraint.constant = graphHeight;
    self.tableView.frame = CGRectMake(0, 0, self.originSize.width-40, self.originSize.height-graphHeight-186);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
}

- (void)setDisplayStrings:(NSArray<NSAttributedString *> *)displayStrings {
    _displayStrings = displayStrings;
    [self.tableView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - tableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayStrings.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX(0, self.tableView.frame.size.height/(((int)self.tableView.frame.size.height)/30));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightRegular];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.row < self.displayStrings.count)
        cell.textLabel.attributedText = self.displayStrings[indexPath.row];
    return cell;
}

#pragma mark - tableView delegate

@end
