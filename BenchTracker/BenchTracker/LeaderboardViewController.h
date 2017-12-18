//
//  LeaderboardViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/16/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaderboardViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSManagedObjectContext *context;

@end
