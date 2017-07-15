//
//  SettingsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)settingsViewControllerDidRequestUserLogout:(SettingsViewController *)settingsVC;
- (void)settingsViewWillDismiss:(SettingsViewController *)settingsVC;
@end

@interface SettingsViewController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic) id<SettingsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@end
