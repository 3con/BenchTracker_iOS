//
//  AchievementsViewController.m
//  BenchTracker
//
//  Created by Chappy Asel on 9/7/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import "AchievementsViewController.h"

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!_fetchedResultsController) { //first load
        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Main fetch error: %@, %@", error, [error userInfo]);
        }
    }
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - collectionView dataSource

#pragma mark - collectionView delegate

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BTAchievement"];
    fetchRequest.fetchLimit = 0;
    fetchRequest.fetchBatchSize = 10;
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

@end
