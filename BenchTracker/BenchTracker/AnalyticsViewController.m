//
//  AnalyticsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "BTWorkoutManager.h"
#import "BTSettings+CoreDataClass.h"
#import "StickCollectionViewFlowLayout.h"
#import "PNChart.h"

@interface AnalyticsViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BTWorkoutManager *workoutManager;
@property (nonatomic) BTSettings *settings;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(20, 0, 80, 0);
    StickCollectionViewFlowLayout *flowLayout = [[StickCollectionViewFlowLayout alloc] init];
    flowLayout.firstItemTransform = .1;
    flowLayout.minimumInteritemSpacing = 50.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AnalyticsCollectionViewCell" bundle:[NSBundle mainBundle]]
                         forCellWithReuseIdentifier:@"Cell"];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - collectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnalyticsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [self colorFromHexString:
        @[@"00BCD4", @"2196F3", @"673AB7", @"EC407A", @"F44336", @"FF9800"][indexPath.row]];
    cell.titleLabel.text =
        @[@"Exercise Progress", @"All Exercises", @"Muscle Split", @"Workout Length", @"Workout Volume", @"Workout Duration"][indexPath.row];
    [cell.seeMoreButton setTitleColor:cell.backgroundColor forState:UIControlStateNormal];
    if (!cell.graphView) {
        PNLineChart *lineChart = [[PNLineChart alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width-40, 230)];
        lineChart.layer.cornerRadius = 8;
        lineChart.clipsToBounds = YES;
        lineChart.showSmoothLines = YES; //FIX in PNLineChart.h: chartLine.fillColor = [[UIColor clearColor] CGColor];
        lineChart.backgroundColor = [UIColor colorWithWhite:1 alpha:.2];
        lineChart.yLabelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        lineChart.xLabelFont = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        lineChart.yFixedValueMin = 220.0;
        lineChart.yFixedValueMax = 280.0;
        lineChart.yLabelNum = (lineChart.yFixedValueMax-lineChart.yFixedValueMin)/20;
        lineChart.xLabelColor = [UIColor whiteColor];
        lineChart.xLabelWidth = 80;
        lineChart.yLabelColor = [UIColor whiteColor];
        [lineChart setXLabels:@[@"J 7",@"",@"J 15",@"",@"J 20",@"",@"J 26",@"",@"J 3",@"",@"J 8"]];
        NSArray *dataArray = @[@230, @245, @240, @243, @254, @250, @248, @260, @263, @267, @261];
        PNLineChartData *data = [PNLineChartData new];
        data.color = [UIColor whiteColor];
        data.lineWidth = 5;
        data.itemCount = lineChart.xLabels.count;
        data.getData = ^(NSUInteger index) { return [PNLineChartDataItem dataItemWithY:[dataArray[index] floatValue]]; };
        lineChart.chartData = @[data];
        [lineChart strokeChart];
        cell.graphView = lineChart;
    }
    return cell;
}

#pragma mark - flowLayout delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width-40, self.collectionView.bounds.size.height-100);
}

#pragma mark - helper methods

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    [[NSScanner scannerWithString:hexString] scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
