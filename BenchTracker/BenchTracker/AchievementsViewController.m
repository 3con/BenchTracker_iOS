//
//  AchievementsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/7/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AchievementsViewController.h"
#import "AchievementCollectionViewCell.h"

@interface AchievementsViewController ()

@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL shouldReloadCollectionView;
@property (nonatomic) NSBlockOperation *blockOperation;

@end

@implementation AchievementsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self loadFlowLayout];
    [self.collectionView registerNib:[UINib nibWithNibName:@"AchievementCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"Cell"];
    if (!_fetchedResultsController) { //first load
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Achievements fetch error: %@, %@", error, [error userInfo]);
        }
    }
}

- (void)loadFlowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    int horizCount = 4;
    if (self.view.frame.size.width < 400) horizCount = 2;
    else if (self.view.frame.size.width < 600) horizCount = 3;
    flowLayout.itemSize = CGSizeMake((self.view.frame.size.width-(horizCount+1)*20)/horizCount, 120);
    flowLayout.minimumInteritemSpacing = 20.0;
    flowLayout.minimumLineSpacing = 20.0;
    flowLayout.sectionInset = UIEdgeInsetsMake(20, 20, 20, 20);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    [self.collectionView setCollectionViewLayout:flowLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self loadFlowLayout];
    [self.collectionView reloadData];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collectionView dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.fetchedResultsController.sections[section].objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AchievementCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell loadWithAchievement:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return cell;
}

#pragma mark - collectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@",indexPath);
}

#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTAchievement"];
    fetchRequest.fetchLimit = 0;
    fetchRequest.fetchBatchSize = 10;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"hidden" ascending:YES],
                                     [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc]
        initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

#pragma mark - fetchedResultsController delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0)
                    self.shouldReloadCollectionView = YES;
                else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            }
            else self.shouldReloadCollectionView = YES;
            break;
        }
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1)
                self.shouldReloadCollectionView = YES;
            else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            } break;
        }
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }]; break;
        }
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }]; break;
        }
        default: break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controllerc {
    if (self.shouldReloadCollectionView) [self.collectionView reloadData];
    else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
