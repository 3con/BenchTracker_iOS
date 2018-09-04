//
//  EditSmartNamesViewController.h
//  BenchTracker
//
//  Created by Chappy Asel on 1/30/18.
//  Copyright © 2018 CD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLForm.h"

@class BTSettings;

typedef enum BTEditSmartNamesSource : NSInteger {
    BTEditSmartNamesSourceSettings,
    BTEditSmartNamesSourceWorkout
} BTEditSmartNamesSource;

@interface EditSmartNamesViewController : XLFormViewController <XLFormDescriptorDelegate>

@property (nonatomic) BTEditSmartNamesSource source;
@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) BTSettings *settings;

@property (nonatomic) NSString *selectedSmartName;

@end
