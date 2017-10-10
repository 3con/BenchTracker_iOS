//
//  SetSummaryCollectionView.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SetSummaryCollectionView.h"
#import "SetFlowLayout.h"

@interface SetSummaryCollectionView ()
@property (nonatomic) UILabel *overlayLabel;
@property (nonatomic) int maxCells;
@end

@implementation SetSummaryCollectionView

@synthesize sets = _sets;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    self.enableOverlayLabel = NO;
    self.userInteractionEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(60, 16);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(2, 10, 2, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self setCollectionViewLayout:flowLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.overlayLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 120, 18)];
    self.overlayLabel.textColor = [UIColor colorWithWhite:1 alpha:.6];
    self.overlayLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold];
    self.overlayLabel.text = @"Tap to add sets";
    [self addSubview:self.overlayLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maxCells = (int)(self.frame.size.width) / 70;
    if (self.visibleCells.count == 0 && self.sets.count > 0)
        [self reloadData];
}

- (void)setSets:(NSMutableArray<NSString *> *)sets {
    _sets = sets;
    [self reloadData];
}

- (NSMutableArray<NSString *> *)sets {
    return _sets;
}

- (void)setEnableOverlayLabel:(BOOL)enableOverlayLabel {
    _enableOverlayLabel = enableOverlayLabel;
    self.overlayLabel.alpha = enableOverlayLabel && (!self.sets || self.sets.count == 0);
}

#pragma mark - collectionView dataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int count = (self.sets) ? MIN(self.sets.count, self.maxCells) : 0;
    self.overlayLabel.alpha = self.enableOverlayLabel && !count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UILabel *label;
    if (cell.subviews.count == 1) {
        cell.backgroundColor = self.backgroundColor;
        cell.layer.cornerRadius = 4;
        cell.clipsToBounds = YES;
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 16)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = self.textColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.allowsDefaultTighteningForTruncation = YES;
        label.minimumScaleFactor = 0.8;
        [cell addSubview:label];
    }
    else label = cell.subviews[1];
    if (self.sets.count > self.maxCells && indexPath.row == self.maxCells-1) {
        label.text = [NSString stringWithFormat:@"+%d more",(int)self.sets.count-(int)self.maxCells];
        label.font = [UIFont systemFontOfSize:8 weight:UIFontWeightHeavy];
    }
    else {
        label.text = [self formattedSetForSet:self.sets[indexPath.row]];
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
