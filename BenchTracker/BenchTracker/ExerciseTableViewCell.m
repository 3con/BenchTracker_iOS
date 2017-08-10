//
//  ExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 6/29/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"

@interface ExerciseTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *colorView1;
@property (weak, nonatomic) IBOutlet UIView *colorView2;
@property (weak, nonatomic) IBOutlet UIView *colorView3;

@property (weak, nonatomic) IBOutlet UIView *aboveSupersetView;
@property (weak, nonatomic) IBOutlet UIView *belowSupersetView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *tempSets;
@property (nonatomic) int maxCells;

@end

@implementation ExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.containerView.backgroundColor = [UIColor BTSecondaryColor];
    self.aboveSupersetView.backgroundColor = [UIColor BTSecondaryColor];
    self.belowSupersetView.backgroundColor = [UIColor BTSecondaryColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.containerView.layer.cornerRadius = 8;
    self.containerView.clipsToBounds = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(60, 16);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 10, 2, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maxCells = (int)(self.frame.size.width-115) / 70;
}

- (void)loadExercise:(BTExercise *)exercise {
    self.leftButtons = @[[MGSwipeButton buttonWithTitle:@"Delete" icon:nil backgroundColor:[UIColor BTRedColor]]];
    self.leftSwipeSettings.transition = MGSwipeTransitionClipCenter;
    if ([self.supersetMode isEqualToString:SUPERSET_NONE]) {
        self.aboveSupersetView.alpha = 0;
        self.belowSupersetView.alpha = 0;
    }
    else if ([self.supersetMode isEqualToString:SUPERSET_ABOVE]) self.aboveSupersetView.alpha = 0;
    else if ([self.supersetMode isEqualToString:SUPERSET_BELOW]) self.belowSupersetView.alpha = 0;
    self.exercise = exercise;
    self.tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:self.exercise.sets];
    if (exercise.iteration) self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",exercise.iteration,exercise.name];
    else                    self.nameLabel.text = exercise.name;
    self.categoryLabel.text = exercise.category;
    [self.collectionView reloadData];
    if (self.color) {
        self.colorView1.backgroundColor = self.color;
        self.colorView2.backgroundColor = self.color;
        self.colorView3.backgroundColor = self.color;
    }
}

#pragma mark - collectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.tempSets) return MIN(self.tempSets.count, self.maxCells);
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *label;
    if (cell.subviews.count == 1) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.layer.cornerRadius = 4;
        cell.clipsToBounds = YES;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor BTSecondaryColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.allowsDefaultTighteningForTruncation = YES;
        label.minimumScaleFactor = 0.8;
        [cell addSubview:label];
    }
    else label = cell.subviews[1];
    if (self.tempSets.count > self.maxCells && indexPath.row == self.maxCells-1) {
        label.text = [NSString stringWithFormat:@"+%d more",(int)self.tempSets.count-(int)self.maxCells];
        label.font = [UIFont systemFontOfSize:8 weight:UIFontWeightHeavy];
    }
    else {
        label.text = [self formattedSetForSet:self.tempSets[indexPath.row]];
        label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    }
    return cell;
}

- (NSString *)formattedSetForSet:(NSString *)set {
    if ([set containsString:@"~"]) return [set substringFromIndex:2];
    NSArray *a = [set componentsSeparatedByString:@" "];
    if ([set containsString:@"s"])
        return (a.count == 3) ? [NSString stringWithFormat:@"%@s (%@)", a[1], a[2]] : [NSString stringWithFormat:@"%@ secs", a[1]];
    return (a.count == 2) ? [NSString stringWithFormat:@"%@x%@", a[0], a[1]] : [NSString stringWithFormat:@"%@", a[0]];
}

#pragma mark - collectionView delegate

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
