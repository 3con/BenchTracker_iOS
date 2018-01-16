#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MMQRCodeMakerUtil.h"
#import "MMScanerLayerView.h"
#import "MMScannerController.h"
#import "UIView+Geometry.h"

FOUNDATION_EXPORT double MMQRCodeScannerVersionNumber;
FOUNDATION_EXPORT const unsigned char MMQRCodeScannerVersionString[];

