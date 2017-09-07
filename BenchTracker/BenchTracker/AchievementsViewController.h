//
//  AchievementsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/7/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class BTSettings;

@interface AchievementsViewController : UIViewController <NSFetchedResultsControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic) NSManagedObjectContext *context;

@property (nonatomic) BTSettings *settings;

@end
