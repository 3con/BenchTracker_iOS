//
//  MMScannerController.m
//  MMQRCodeScanner
//
//  Created by LEA on 2017/4/5.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "MMScannerController.h"
#import <AVFoundation/AVFoundation.h>

@interface MMScannerController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, strong) MMScanerLayerView *scanView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *warnView;
@property (nonatomic, strong) UILabel *warnLab;
@property (nonatomic, strong) UILabel *noteLab;
@property (nonatomic, strong) UIView *flashlightView;

@end

@implementation MMScannerController

#pragma mark - ## 生命周期 ##
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"扫描";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.session startRunning];
    [self.scanView startAnimation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    [self.scanView stopAnimation];
}

#pragma mark - ## 扫描控制 ##
- (void)startScan
{
    [self.session startRunning];
}

- (void)stopScan
{
    [self.session stopRunning];
}

#pragma mark - ## 设置UI ##
- (void)setUpUI
{
    //## 默认值设置
    if (!self.qrScanArea.size.height || !self.qrScanArea.size.width) {
        self.qrScanArea = CGRectMake(40, 80, self.view.width-80, self.view.width-80);
    }
    if (!self.qrScanLayerBorderColor) {
        self.qrScanLayerBorderColor = [UIColor colorWithRed:0/255.5 green:200.0/255.0 blue:94.0/255.0 alpha:1.0];
    }
    if (!self.qrScanLineAnimateDuration) {
        self.qrScanLineAnimateDuration = 0.01;
    }
    
    //## 导航栏设置
    if (self.showGalleryOption) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"图库" style:UIBarButtonItemStylePlain target:self action:@selector(galleryClicked)];
    }
    
    //## 设置采集
    //1.获取摄像设备、输入输出流
    NSError *err = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&err];
    if (!input) {
        return;
    }
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //1.1 持续自动曝光
    NSError *error = nil;
    if ([self.inputDevice lockForConfiguration:&error]) {
        [self.inputDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [self.inputDevice setTorchMode:AVCaptureTorchModeAuto];
        [self.inputDevice unlockForConfiguration];
    }
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    [self.session addInput:input];
    [self.session addOutput:output];
    //1.2 是否支持条形码
    if (self.supportBarcode) {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode128Code];
    } else {
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
 
    //2 创建预览图层
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    //3 设置扫描区域
    [[NSNotificationCenter defaultCenter]addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.qrScanArea];
    }];
    [self.view.layer insertSublayer:layer atIndex:0];
    //4.添加扫描框等
    [self.view addSubview:self.scanView];
    [self.view addSubview:self.noteLab];
    [self.view addSubview:self.warnView];
    self.warnView.hidden = YES;
    //5.手电筒
    if (self.showFlashlight) {
        [self.view addSubview:self.flashlightView];
    }
    //6.风火轮
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
}

#pragma mark - ## getter ##
- (MMScanerLayerView *)scanView
{
    if (!_scanView) {
        _scanView = [[MMScanerLayerView alloc] initWithFrame:self.view.bounds];
        _scanView.qrScanArea = self.qrScanArea;
        _scanView.qrScanLayerBorderColor = self.qrScanLayerBorderColor;
        _scanView.qrScanLineAnimateDuration = self.qrScanLineAnimateDuration;
        _scanView.qrScanLineImageName = self.qrScanLineImageName;
        _scanView.contentMode = UIViewContentModeRedraw;
        _scanView.backgroundColor = [UIColor clearColor];
    }
    return _scanView;
}

- (AVCaptureDevice *)inputDevice
{
    if (!_inputDevice) {
        _inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _inputDevice;
}

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.center = CGPointMake(self.qrScanArea.origin.x+self.qrScanArea.size.width/2, self.qrScanArea.origin.y+self.qrScanArea.size.height/2);
    }
    return _spinner;
}

- (UIView *)warnView
{
    if (!_warnView) {
        _warnView = [[UIView alloc] initWithFrame:self.view.bounds];
        _warnView.backgroundColor = [UIColor blackColor];
        _warnView.alpha = 0.7;
        _warnView.userInteractionEnabled = YES;
        [_warnView addSubview:self.warnLab];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureResponse)];
        [_warnView addGestureRecognizer:tapGestureRecognizer];
    }
    return _warnView;
}

- (UILabel *)warnLab
{
    if (!_warnLab) {
        _warnLab = [[UILabel alloc] initWithFrame:self.qrScanArea];
        _warnLab.numberOfLines = 0;
        _warnLab.font = [UIFont systemFontOfSize:14.0];
        _warnLab.textColor = [UIColor whiteColor];
        _warnLab.backgroundColor = [UIColor clearColor];
        
        NSString *warnStr = @"未发现二维码\n轻触屏幕继续";
        if (self.supportBarcode) {
            warnStr = @"未发现二维码/条形码\n轻触屏幕继续";
        }
        
        //设置行距
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:warnStr];
        NSMutableParagraphStyle *stype = [[NSMutableParagraphStyle alloc] init];
        stype.lineSpacing = 3;
        stype.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:stype range:NSMakeRange(0,[warnStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:NSMakeRange(0,warnStr.length-6)];
        _warnLab.attributedText = attributedString;
    }
    return _warnLab;
}

- (UILabel *)noteLab
{
    if (!_noteLab) {
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.qrScanArea.origin.y+self.qrScanArea.size.height+10, self.view.width, 20)];
        _noteLab.textColor = [UIColor grayColor];
        _noteLab.text = @"将二维码置于框内，即可自动扫描";
        _noteLab.textAlignment = NSTextAlignmentCenter;
        _noteLab.backgroundColor = [UIColor clearColor];
        _noteLab.font = [UIFont systemFontOfSize:12.0];
    }
    return _noteLab;
}

- (UIView *)flashlightView
{
    if (!_flashlightView) {
        _flashlightView = [[UIView alloc] initWithFrame:CGRectMake(0, self.noteLab.bottom+10, self.view.width, 80)];
        _flashlightView.backgroundColor = [UIColor clearColor];
        
        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake((_flashlightView.width-60)/2, 0, 60, 60)];
        [flashBtn setImage:[UIImage imageNamed:@"scan_flashlight"] forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(flashClicked) forControlEvents:UIControlEventTouchUpInside];
        [_flashlightView addSubview:flashBtn];

        UILabel *noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, flashBtn.bottom-10, _flashlightView.width, 20)];
        noteLab.textColor = [UIColor grayColor];
        noteLab.text = @"轻触照亮";
        noteLab.textAlignment = NSTextAlignmentCenter;
        noteLab.backgroundColor = [UIColor clearColor];
        noteLab.font = [UIFont systemFontOfSize:12.0];
        [_flashlightView addSubview:noteLab];
    }
    return _flashlightView;
}

#pragma mark - ## 手电筒 ##
- (void)flashClicked
{
    if (self.inputDevice.torchMode == AVCaptureTorchModeOn) {
        [self.inputDevice lockForConfiguration:nil];
        [self.inputDevice setTorchMode:AVCaptureTorchModeOff];
        [self.inputDevice unlockForConfiguration];
    } else {
        [self.inputDevice lockForConfiguration:nil];
        [self.inputDevice setTorchMode:AVCaptureTorchModeOn];
        [self.inputDevice unlockForConfiguration];
    }
}

#pragma mark - ## 继续扫描 ##
- (void)gestureResponse
{
    self.warnView.hidden = YES;
}

#pragma mark - ## 图库选择 ##
- (void)galleryClicked
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.navigationBar.tintColor = [UIColor blackColor];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //1. 获取图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //2. 初始化扫描仪，设置设别类型和识别质量
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    //3. 扫描获取的特征组
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    //4. 获取扫描结果
    if ([features count]) {
        self.warnView.hidden = YES;
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanConetent = feature.messageString;
        //5. 回传
        if (self.completion) self.completion(scanConetent);
    } else {
        self.warnView.hidden = NO;
    }
    //6. dismiss图库
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        self.warnView.hidden = YES;
        //1. 获取扫描结果
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *scanConetent = metadataObject.stringValue;
        //2. 回传
        if (self.completion) {
            self.completion(scanConetent);
        }
        //3. 停止扫描
        [self.session stopRunning];
    }
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
