//
//  AnalyticsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AnalyticsViewController.h"
#import "ZFModalTransitionAnimator.h"
#import "BTSettings+CoreDataClass.h"
#import "BTWorkoutManager.h"
#import "StickCollectionViewFlowLayout.h"
#import "BTAnalyticsLineChart.h"
#import "BTAnalyticsPieChart.h"
#import "BTAnalyticsBarChart.h"
#import "BTRecentWorkoutsManager.h"
#import "AnalyticsDetailViewController.h"

@interface AnalyticsViewController ()

@property (nonatomic) ZFModalTransitionAnimator *animator;

@property (nonatomic) BTRecentWorkoutsManager *recentWorkoutsManager;
@property (nonatomic) BTSettings *settings;

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.settings = [BTSettings sharedInstance];
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
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnalyticsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.originSize = CGSizeMake(self.view.frame.size.width-40, self.view.frame.size.height-172);
    cell.graphHeight = (indexPath.row == 2) ? 0 : 210;
    cell.backgroundColor = [self colorFromHexString:
        @[@"00BCD4",
          @"2ECC71",
          @"2196F3",
          @"673AB7",
          @"EC407A",
          @"F44336",
          @"FF9800"][indexPath.row]];
    cell.titleLabel.text =
        @[@"Weekly Summary",
          @"Favorite Exercises",
          @"Track your Progress",
          @"Volume",
          @"Duration",
          @"Number of Exercises",
          @"Number of Sets",][indexPath.row];
    cell.subtitleLabel.text =
        @[@"Week of ---",
          @"Recent Workouts",
          @"",
          @"Recent Workouts",
          @"Recent Workouts",
          @"Recent Workouts",
          @"Recent Workouts",][indexPath.row];
    [cell.seeMoreButton setTitleColor:cell.backgroundColor forState:UIControlStateNormal];
    NSMutableArray <NSAttributedString *> *displayStrings = [NSMutableArray array];
    if (indexPath.row == 0) { //pie chart
        cell.subtitleLabel.text = [NSString stringWithFormat:@"Week of %@",[self.recentWorkoutsManager formattedFirstDayOfWeek]];
        NSDictionary *data = [self.recentWorkoutsManager workoutExerciseTypesThisWeek];
        BTAnalyticsPieChart *pieChart = [[BTAnalyticsPieChart alloc]
                                         initWithFrame:CGRectMake((collectionView.frame.size.width-250)/2.0, 20, 170, 170) items:[BTAnalyticsPieChart pieDataForDictionary:data]];
        cell.graphView = pieChart;
        NSArray <NSString *> *data2 = [self.recentWorkoutsManager otherDataThisWeek];
        NSArray <NSString *> *strArr = @[@"Workouts", @"Exercises", @"Sets", @"Lifted"];
        for (int i = 0; i < data2.count; i++) {
            NSMutableAttributedString *mS = [[NSMutableAttributedString alloc] initWithString:
                                             [NSString stringWithFormat:@"%@ %@", data2[i], strArr[i]]];
            [mS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy]}
                        range:NSMakeRange(0, data2[i].length)];
            [displayStrings addObject:mS];
        }
    }
    else if (indexPath.row == 1) { //fav exercises
        NSDictionary *data = [self.recentWorkoutsManager workoutExercises];
        BTAnalyticsBarChart *barChart = [[BTAnalyticsBarChart alloc] initWithFrame:CGRectMake(5, 10, collectionView.frame.size.width-70, 198)];
        [barChart setBarData:data];
        cell.graphView = barChart;
        for (int i = 0; i < barChart.yValues.count; i++) {
            NSMutableAttributedString *mS = [[NSMutableAttributedString alloc] initWithString:
                                             [NSString stringWithFormat:@"%@ %@", barChart.yValues[i], barChart.xLabels[i]]];
            [mS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy]} range:NSMakeRange(0, 2)];
            [displayStrings addObject:mS];
        }
    }
    else if (indexPath.row == 2) { //all exercises
        NSArray *data = [self.recentWorkoutsManager workoutExercises].allKeys;
        for (int i = 0; i < MIN(data.count, 20); i++)
            [displayStrings addObject:[[NSMutableAttributedString alloc] initWithString:data[i]]];
    }
    else if (indexPath.row > 2) { //line charts
        NSArray *data;
        NSString *suffix;
        BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc] initWithFrame:CGRectMake(5, 10, collectionView.frame.size.width-60, 198)];
        [lineChart setXAxisData:[self.recentWorkoutsManager workoutShortDates]];
        if (indexPath.row == 3) {
            data = [self.recentWorkoutsManager workoutVolumes];
            suffix = [NSString stringWithFormat:@"k %@", self.settings.weightSuffix];
        }
        else if (indexPath.row == 4) {
            data = [self.recentWorkoutsManager workoutDurations];
            suffix = @" min";
        }
        else if (indexPath.row == 5) {
            data = [self.recentWorkoutsManager workoutNumExercises];
            suffix = @"";
        }
        else {
            data = [self.recentWorkoutsManager workoutNumSets];
            suffix = @"";
        }
        [lineChart setYAxisData:data];
        cell.graphView = lineChart;
        NSArray *dates = [self.recentWorkoutsManager workoutDates];
        for (int i = 0; i < data.count; i++) {
            NSString *intVal = [NSString stringWithFormat:@"%d",[data[i] intValue]];
            NSMutableAttributedString *mS = [[NSMutableAttributedString alloc] initWithString:
                                             [NSString stringWithFormat:@"%@%@ %@", intVal, suffix, dates[i]]];
            [mS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy]}
                        range:NSMakeRange(0, intVal.length+suffix.length)];
            [displayStrings insertObject:mS atIndex:0];
        }
    }
    cell.displayStrings = displayStrings;
    return cell;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self presentAnalyticsDetailViewControllerWithIndex:indexPath.row
                                                   cell:(AnalyticsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath]];
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

#pragma mark - view handling

- (void)presentAnalyticsDetailViewControllerWithIndex:(NSInteger)index cell:(AnalyticsCollectionViewCell *)cell {
    AnalyticsDetailViewController *adVC;
    if (index == 0)     adVC = [[NSBundle mainBundle] loadNibNamed:@"ADMuscleSplitViewController" owner:self options:nil].firstObject;
    else if (index < 3) adVC = [[NSBundle mainBundle] loadNibNamed:@"ADExercisesViewController" owner:self options:nil].firstObject;
    else                adVC = [[NSBundle mainBundle] loadNibNamed:@"ADWorkoutsViewController" owner:self options:nil].firstObject;
    adVC.context = self.context;
    adVC.settings = self.settings;
    adVC.color = cell.backgroundColor;
    adVC.titleString = cell.titleLabel.text;
    self.animator = [[ZFModalTransitionAnimator alloc] initWithModalViewController:adVC];
    self.animator.bounces = NO;
    self.animator.dragable = YES;
    self.animator.behindViewAlpha = 0.6;
    self.animator.behindViewScale = 1.0;
    self.animator.transitionDuration = 0.35;
    self.animator.direction = ZFModalTransitonDirectionRight;
    adVC.transitioningDelegate = self.animator;
    adVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:adVC animated:YES completion:nil];
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
