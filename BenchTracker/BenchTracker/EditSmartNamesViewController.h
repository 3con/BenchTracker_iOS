//
//  EditSmartNamesViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 1/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTSettings;

@interface EditSmartNamesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) BTSettings *settings;

@end
