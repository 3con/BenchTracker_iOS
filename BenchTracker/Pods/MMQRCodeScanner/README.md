# MMQRCodeScanner

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/dexianyinjiu/MMQRCodeScanner/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/MMQRCodeScanner.svg?style=flat)](https://cocoapods.org/pods/MMQRCodeScanner)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/MMQRCodeScanner.svg?style=flat)](https://cocoapods.org/pods/MMQRCodeScanner)&nbsp;

这是一个使用于iOS系统的二维码扫描和制作工具，带有UI，UI也可根据属性自行修改。支持条形码扫描以及识别图片中的二维码，制作二维码可以指定颜色、大小、可嵌入logo。

![MMQRCodeScanner](MMQRCodeScanner.gif)

### 安装 [CocoaPods]

1. `pod 'MMQRCodeScanner', '~> 1.1'`;
2. `pod install` / `pod update`;
3. `#import <MMQRCodeScanner/MMScannerController.h>`;
4. `plist`需添加`Privacy - Camera Usage Description`和`Privacy - Photo Library Usage Description`


### 扫描的使用方式：

`MMScannerController`外部可修改属性如下，使用时可自行设置。

```objc
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
```

示例如下：

```objc
_scanner = [[MMScannerController alloc] init];
_scanner.showGalleryOption = YES;
_scanner.showFlashlight = YES;
_scanner.supportBarcode = YES;
[_scanner setCompletion:^(NSString *scanConetent) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"扫描内容如下："
                                                        message:scanConetent
                                                       delegate:weakSelf
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
    [alertView show];
}];
[self.navigationController pushViewController:_scanner animated:YES];
```

### 制作的使用方式：

`MMQRCodeMakerUtil`提供同步和异步制作方式：

```objc
/**
制作二维码[同步]

@param qrContent 二维码内容
@param logoImage 中间的填充图片[logo]
@param qrColor 二维码颜色
@param qrWidth 二维码宽度
@return 二维码
*/
+ (UIImage *)qrImageWithContent:(NSString *)qrContent
                      logoImage:(UIImage *)logoImage
                        qrColor:(UIColor *)qrColor
                        qrWidth:(CGFloat)qrWidth;

/**
制作二维码[异步]

@param qrContent 二维码内容
@param logoImage 中间的填充图片[logo]
@param qrColor 二维码颜色
@param qrWidth 二维码宽度
@param completion 完成回调
*/
+ (void)qrImageWithContent:(NSString *)qrContent
                 logoImage:(UIImage *)logoImage
                   qrColor:(UIColor *)qrColor
                   qrWidth:(CGFloat)qrWidth
                completion:(void (^)(UIImage *image))completion;
```

示例如下：

```objc
NSString *qrContent = @"Hello, this is a two-dimensional code";
UIImage *qrImage = [MMQRCodeMakerUtil qrImageWithContent:qrContent
                                               logoImage:[UIImage imageNamed:@"logo.jpg"]
                                                 qrColor:[UIColor blackColor]
                                                 qrWidth:240];
```

### 使用要求

`iOS 8.0+` 
`Xcode 7.0+`


### 许可证

MIT



