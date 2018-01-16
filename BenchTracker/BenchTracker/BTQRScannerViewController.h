//
//  BTQRScannerViewController.h
//  MMQRCodeScanner
//
//  Created by LEA on 2017/4/5.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Geometry.h"
#import "MMQRCodeMakerUtil.h"
#import "MMScanerLayerView.h"

@class BTQRScannerViewController;

@protocol BTQRScannerViewControllerDelegate <NSObject>
- (void)qrScannerVC:(BTQRScannerViewController *)qrVC didDismissWithScannedString:(NSString *)string;
@end

@interface BTQRScannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic) id<BTQRScannerViewControllerDelegate> delegate;

- (void)startScan;
- (void)stopScan;

@end
