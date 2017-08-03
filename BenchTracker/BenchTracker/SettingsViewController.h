//
//  SettingsViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 7/2/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "XLForm.h"

@class SettingsViewController;

@protocol SettingsViewControllerDelegate <NSObject>
- (void)settingsViewWillDismiss:(SettingsViewController *)settingsVC;
@end

@interface SettingsViewController : XLFormViewController <XLFormDescriptorDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic) id<SettingsViewControllerDelegate> delegate;

@property (nonatomic) NSManagedObjectContext *context;

@end
