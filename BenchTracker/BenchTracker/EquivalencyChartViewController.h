//
//  EquivalencyChartViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTExercise+CoreDataClass.h"
#import "BTSettings+CoreDataClass.h"
#import "SetCollectionView.h"

@interface EquivalencyChartViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, SetCollectionViewDataSource>

@property (nonatomic) BTSettings *settings;

@property (nonatomic) BTExercise *exercise;

@end
