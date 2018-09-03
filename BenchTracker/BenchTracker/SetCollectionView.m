//
//  SetCollectionView.m
//  BenchTracker
//
//  Created by Chappy Asel on 8/25/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "SetCollectionView.h"
#import "SetCollectionViewCell.h"
#import "SetFlowLayout.h"
#import "BTSettings+CoreDataClass.h"

@interface SetCollectionView()
@property (nonatomic) UISelectionFeedbackGenerator *feedbackSelection;
@property (nonatomic) UIImpactFeedbackGenerator *feedbackImpact;
@property (nonatomic) UINotificationFeedbackGenerator *feedbackNotification;
@end

@implementation SetCollectionView

@synthesize sets = _sets;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    self.showsHorizontalScrollIndicator = NO;
    self.display1RM = NO;
    SetFlowLayout *flowLayout = [[SetFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(70, 45);
    flowLayout.minimumInteritemSpacing = 10.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self setCollectionViewLayout:flowLayout];
    [self registerNib:[UINib nibWithNibName:@"SetCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    [self registerClass:[BTCollectionViewCell class] forCellWithReuseIdentifier:@"ACell"];
    self.feedbackSelection = [[UISelectionFeedbackGenerator alloc] init];
    self.feedbackImpact = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    self.feedbackNotification = [[UINotificationFeedbackGenerator alloc] init];
}

- (void)setSets:(NSMutableArray<NSString *> *)sets {
    _sets = sets;
    [self reloadData];
}

- (NSMutableArray<NSString *> *)sets {
    return _sets;
}

- (void)setDisplay1RM:(BOOL)display1RM {
    _display1RM = display1RM;
    [self reloadData];
}

#pragma mark - collectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.sets.count+1;
}

- (CGSize)sizeForItemWithColumnIndex:(NSUInteger)columnIndex {
    return CGSizeMake(70, 45);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { //first cell: add set
        BTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ACell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor BTSecondaryColor];
        cell.layer.cornerRadius = 12;
        cell.clipsToBounds = YES;
        if (cell.subviews.count == 1) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, -2, 70, 45)];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [self lighterColorForColor:[UIColor BTSecondaryColor]];
            label.text = @"+";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:34 weight:UIFontWeightHeavy];
            [cell addSubview:label];
        }
        return cell;
    }
    SetCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.display1RM = self.display1RM;
    [cell loadSetWithString:self.sets[self.sets.count-(indexPath.row-1)-1] weightSuffix:self.settings.weightSuffix];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) { //add set
        if (self.sets.count < 12) {
            [self performBatchUpdates:^{
                NSString *result = [self.setDataSource setToAddForSetCollectionView:self];
                if (result) {
                    [self.sets addObject:result];
                    [self insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]]];
                    [self.feedbackImpact impactOccurred];
                } else {
                    [self animateCancelAdd];
                    [self.feedbackNotification notificationOccurred:UINotificationFeedbackTypeWarning];
                }
            } completion:nil];
        } else {
            [self animateCancelAdd];
            [self.feedbackNotification notificationOccurred:UINotificationFeedbackTypeError];
        }
    }
    else { //delete set
        [self.feedbackSelection selectionChanged];
        [(SetCollectionViewCell *)[self cellForItemAtIndexPath:indexPath] performDeleteAnimationWithDuration:.4];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,.2*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self performBatchUpdates:^{
                [self.sets removeObjectAtIndex:self.sets.count-(indexPath.row-1)-1];
                [self deleteItemsAtIndexPaths:@[indexPath]];
            } completion:nil];
        });
    }
}

- (void)animateCancelAdd {
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *label = cell.subviews[1];
    [UIView animateWithDuration:.2 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        label.text = @"x";
        [UIView animateWithDuration:.2 animations:^{
            label.alpha = 1;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:.2 animations:^{
                    label.alpha = 0;
                } completion:^(BOOL finished) {
                    label.text = @"+";
                    [UIView animateWithDuration:.2 animations:^{
                        label.alpha = 1;
                    } completion:nil];
                }];
            });
        }];
    }];
}

#pragma mark - color methods

- (UIColor *)lighterColorForColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:MIN(b*2.5, 1.0) alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)color {
    CGFloat h, s, b, a;
    if ([color getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h saturation:s brightness:b*0.8 alpha:a];
    return nil;
}

@end
