//
//  EquivalencyChartViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 8/1/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSettings+CoreDataClass.h"

@interface EquivalencyChartViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic) BTSettings *settings;

@end
