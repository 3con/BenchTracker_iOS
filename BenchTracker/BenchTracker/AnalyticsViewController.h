//
//  AnalyticsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@class AnalyticsViewController;

@protocol AnalyticsViewControllerDelegate <NSObject>

@end

@interface AnalyticsViewController : UIViewController <SettingsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) id<AnalyticsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@end
