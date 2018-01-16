//
//  EditUsernameViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 12/18/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTUser;
@class EditUsernameViewController;

@protocol EditUsernameViewControllerDelegate <NSObject>
- (void)editUsernameViewControllerWillDismissWithUpdatedUsername:(EditUsernameViewController *)euVC;
@end

@interface EditUsernameViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>

@property (nonatomic) id<EditUsernameViewControllerDelegate> delegate;

@property (nonatomic) BTUser *user;
@property (nonatomic) CGPoint originPoint;

@end
