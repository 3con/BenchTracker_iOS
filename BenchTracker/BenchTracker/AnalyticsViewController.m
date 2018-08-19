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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) CGSize itemSize;

@end

@implementation AnalyticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.navView.layer.borderWidth = 1.0;
    self.navView.layer.borderColor = [UIColor BTNavBarLineColor].CGColor;
    self.titleLabel.textColor = [UIColor BTTextPrimaryColor];
    [self.backButton setTitleColor:[UIColor BTTextPrimaryColor] forState:UIControlStateNormal];
    self.settings = [BTSettings sharedInstance];
    self.collectionView.backgroundColor = [UIColor BTTableViewBackgroundColor];
    self.recentWorkoutsManager = [[BTRecentWorkoutsManager alloc] init];
    self.recentWorkoutsManager.maxFetch = 8;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    StickCollectionViewFlowLayout *flowLayout = [[StickCollectionViewFlowLayout alloc] init];
    flowLayout.firstItemTransform = .1;
    flowLayout.minimumInteritemSpacing = 20.0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AnalyticsCollectionViewCell" bundle:[NSBundle mainBundle]]
                         forCellWithReuseIdentifier:@"Cell"];
    [self determineCollectionViewFormattingWithSize:self.view.frame.size];
    [Log event:@"AnalyticsVC: Presentation" properties:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self determineCollectionViewFormattingWithSize:size];
}

- (void)determineCollectionViewFormattingWithSize:(CGSize)size {
    float insets = 0;
    if (size.width < 700) {       //(1 card) iPhone
        self.itemSize = CGSizeMake(MIN(400, size.width-40), MIN(570, size.height-172));
        insets = 0;
    }
    else if (size.width < 980) {  //(2 cards) iPads portrait: (768x1024, 834x1112)
        self.itemSize = CGSizeMake(MIN(400, (size.width-60)/2), 550);
        insets = (size.width-(self.itemSize.width*2))/3;
    }
    else if (size.width < 1300) { //(3 cards) iPads landscape: (1024x768, 1024x1366, 1112x834)
        self.itemSize = CGSizeMake(MIN(400, (size.width-80)/3), 550);
        insets = (size.width-(self.itemSize.width*3))/4;
    }
    else {                        //(4 cards) iPad 12.9 landscape: (1366x1024)
        self.itemSize = CGSizeMake(MIN(400, (size.width-100)/4), 500);
        insets = (size.width-(self.itemSize.width*4))/5;
    }
    self.collectionView.contentInset = UIEdgeInsetsMake(20, insets, 80, insets);
    [self.collectionView reloadData];
}

- (IBAction)doneButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AnalyticsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.originSize = self.itemSize;
    cell.graphHeight = (indexPath.row == 2) ? 0 : 210;
    cell.backgroundColor = [UIColor BTVibrantColors][indexPath.row];
    cell.titleLabel.text =
        @[@"Weekly Summary",
          @"Favorite Exercises",
          @"Track Your Progress",
          @"Volume",
          @"Duration",
          @"Number of Exercises",
          @"Number of Sets",][indexPath.row];
    cell.subtitleLabel.text =
        @[@"Week of ---",
          @"Recent Workouts",
          @"All Exercises",
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
                                         initWithFrame:CGRectMake((cell.originSize.width-210)/2.0, 20, 170, 170)
                                                 items:[BTAnalyticsPieChart pieDataForDictionary:data]];
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
        BTAnalyticsBarChart *barChart = [[BTAnalyticsBarChart alloc] initWithFrame:CGRectMake(5, 10, cell.originSize.width-30, 198)];
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
        BTAnalyticsLineChart *lineChart = [[BTAnalyticsLineChart alloc] initWithFrame:CGRectMake(5, 10, cell.originSize.width-20, 198)];
        NSArray *xAxisData = [self.recentWorkoutsManager workoutShortDates];
        [lineChart setXAxisData:[[xAxisData reverseObjectEnumerator] allObjects]];
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
        [lineChart setYAxisData:[[data reverseObjectEnumerator] allObjects]];
        cell.graphView = lineChart;
        NSArray *dates = [self.recentWorkoutsManager workoutDates];
        for (int i = 0; i < data.count; i++) {
            NSString *intVal = [NSString stringWithFormat:@"%d",[data[i] intValue]];
            NSMutableAttributedString *mS = [[NSMutableAttributedString alloc] initWithString:
                                             [NSString stringWithFormat:@"%@%@ %@", intVal, suffix, dates[i]]];
            [mS setAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightHeavy]}
                        range:NSMakeRange(0, intVal.length+suffix.length)];
            [displayStrings addObject:mS];
        }
    }
    cell.displayStrings = displayStrings;
    return cell;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [Log event:@"AnalyticsVC: Selected card" properties:@{@"Card": @(indexPath.row)}];
    [self presentAnalyticsDetailViewControllerWithIndex:indexPath.row
                                                   cell:(AnalyticsCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath]];
}

#pragma mark - flowLayout delegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 20;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
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
    if (index == 0)     adVC = [[NSBundle mainBundle] loadNibNamed:@"ADWeeklySummaryViewController" owner:self options:nil].firstObject;
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
    return [UIColor statusBarStyle];
}

@end
