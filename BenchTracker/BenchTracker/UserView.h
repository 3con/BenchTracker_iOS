//
//  UserView.h
//  BenchTracker
//
//  Created by Chappy Asel on 9/8/17.
//  Copyright © 2017 CD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BTUser;

@interface UserView : UIView

- (void)loadUser:(BTUser *)user;

- (void)animateIn;

@end
