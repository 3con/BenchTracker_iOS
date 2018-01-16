//
//  AnalyticsDetailViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/10/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BTSettings+CoreDataClass.h"

@interface AnalyticsDetailViewController : UIViewController

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) UIColor *color;
@property (nonatomic) NSString *titleString;

@end
