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
#import "BTAnalyticsLineChart.h"
#import "BTAnalyticsPieChart.h"
#import "BTAnalyticsBarChart.m"
#import "BTRecentWorkoutsManager.h"

@interface AnalyticsViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BTRecentWorkoutsManager *recentWorkoutsManager;
@property (nonatomic) BTSettings *settings;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTSettings"];
    NSError *error;
    self.settings = [self.context executeFetchRequest:fetchRequest error:&error].firstObject;
    if (error) NSLog(@"settings fetcher errror: %@",error);
    self.recentWorkoutsManager = [[BTRecentWorkoutsManager alloc] init];
    self.recentWorkoutsManager.maxFetch = 11;
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
        @[@"00BCD4",
          @"2196F3",
          @"673AB7",
          @"EC407A",
          @"F44336",
          @"FF9800"][indexPath.row]];
    cell.titleLabel.text =
        @[@"Favorite Exercises",
          @"All Exercises",
          @"Muscle Split",
          @"Number of Exercises",
          @"Volume (1000s of lbs)",
          @"Duration (minutes)"][indexPath.row];
    [cell.seeMoreButton setTitleColor:cell.backgroundColor forState:UIControlStateNormal];
    if (!cell.graphView) {
        if (indexPath.row == 0) {
            BTAnalyticsBarChart *barChart = [[BTAnalyticsBarChart alloc] initWithFrame:CGRectMake(5, 10, cell.frame.size.width-20, 198)];
            [barChart setBarData:[self.recentWorkoutsManager workoutExercises]];
            cell.graphView = barChart;
        }
        if (indexPath.row == 2) {
            BTAnalyticsPieChart *pieChart = [[BTAnalyticsPieChart alloc] initWithFrame:CGRectMake((cell.frame.size.width-210)/2.0, 20, 170, 170)
                items:[BTAnalyticsPieChart pieDataForDictionary:[self.recentWorkoutsManager workoutExerciseTypes]
                                                  withColorDict:[NSKeyedUnarchiver unarchiveObjectWithData:self.settings.exerciseTypeColors]]];
            cell.graphView = pieChart;
        }
        else if (indexPath.row > 2) { //line charts
            BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc] initWithFrame:CGRectMake(5, 10, cell.frame.size.width-20, 198)];
            [lineChart setXAxisData:[self.recentWorkoutsManager workoutDates]];
            if (indexPath.row == 3) [lineChart setYAxisData:[self.recentWorkoutsManager workoutNumExercises]];
            else if (indexPath.row == 4) [lineChart setYAxisData:[self.recentWorkoutsManager workoutVolumes]];
            else [lineChart setYAxisData:[self.recentWorkoutsManager workoutDurations]];
            cell.graphView = lineChart;
        }
    }
    if (indexPath.row == 0) [(BTAnalyticsPieChart *)cell.graphView strokeChart];
    if (indexPath.row == 2) [(BTAnalyticsPieChart *)cell.graphView strokeChart];
    if (indexPath.row > 2) [(BTAnalyticsLineChart *)cell.graphView strokeChart];
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
