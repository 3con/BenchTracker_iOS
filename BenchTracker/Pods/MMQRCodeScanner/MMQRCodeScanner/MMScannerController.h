//
//  MMScannerController.h
//  MMQRCodeScanner
//
//  Created by LEA on 2017/4/5.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Geometry.h"
#import "MMQRCodeMakerUtil.h"
#import "MMScanerLayerView.h"

@interface MMScannerController : UIViewController

//透明的区域[扫描区 | 默认：左边距40，上边距80]
@property (nonatomic, assign) CGRect qrScanArea;
//动画间隔时间[默认值:0.01s]
@property (nonatomic, assign) double qrScanLineAnimateDuration;
//四角颜色[默认：R:0/255.5  G:200.0/255.0  B:94.0/255.0]
@property (nonatomic, strong) UIColor *qrScanLayerBorderColor;
//扫描线图片[默认：使用resource下的scan_line]
@property (nonatomic, copy) NSString *qrScanLineImageName;
//是否支持条码[默认显示：NO]
@property (nonatomic, assign) BOOL supportBarcode;
//是否显示'闪光灯'[默认显示：NO]
@property (nonatomic, assign) BOOL showFlashlight;
//是否显示'图库'[默认显示：NO]
@property (nonatomic, assign) BOOL showGalleryOption;
//扫描内容回传
@property (nonatomic, copy) void (^completion)(NSString *scanConetent);

//## 扫描控制
- (void)startScan;
- (void)stopScan;

@end
