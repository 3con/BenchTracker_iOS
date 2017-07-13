//
//  ADEDExerciseTableViewCell.m
//  BenchTracker
//
//  Created by Chappy Asel on 7/13/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "ADEDExerciseTableViewCell.h"
#import "BTExercise+CoreDataClass.h"
#import "BTWorkout+CoreDataClass.h"

@interface ADEDExerciseTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *tempSets;
@property (nonatomic) int maxCells;

@end

@implementation ADEDExerciseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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

- (void)loadExercise:(BTExercise *)exercise {
    self.contentView.backgroundColor = self.color;
    self.badgeLabel.text = [NSString stringWithFormat:@"1RM: %lld lbs",exercise.oneRM];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM d ''yy";
    self.dateLabel.text = [formatter stringFromDate:exercise.workout.date];
    if (exercise.iteration) self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",exercise.iteration,exercise.name];
    else                    self.titleLabel.text = exercise.name;
    self.tempSets = [NSKeyedUnarchiver unarchiveObjectWithData:exercise.sets];
    self.maxCells = (int)self.collectionView.frame.size.width / 70;
    [self.collectionView reloadData];
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
        label.textColor = self.color;
        label.textAlignment = NSTextAlignmentCenter;
        label.allowsDefaultTighteningForTruncation = YES;
        label.minimumScaleFactor = 0.8;
        [cell addSubview:label];
    }
    else label = cell.subviews[1];
    if (self.tempSets.count > self.maxCells && indexPath.row == self.maxCells-1) {
        label.text = [NSString stringWithFormat:@"+%ld more",self.tempSets.count-self.maxCells];
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

@end
