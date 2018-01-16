//
//  UserViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/6/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@class UserViewController;

@protocol UserViewControllerDelegate <NSObject>
- (void)userViewControllerSettingsDidUpdate:(UserViewController *)userVC;
@end

@interface UserViewController : UIViewController <SettingsViewControllerDelegate>

@property (nonatomic) id<UserViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@property (nonatomic) BOOL forwardToAcheivements;

@end
