//
//  BTQRScannerViewController.m
//  MMQRCodeScanner
//
//  Created by LEA on 2017/4/5.
//  Copyright © 2017年 LEA. All rights reserved.
//

#import "BTQRScannerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BTAchievement+CoreDataClass.h"

@interface BTQRScannerViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *navView;

@property (nonatomic, strong) MMScanerLayerView *scanView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *inputDevice;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIView *warnView;
@property (nonatomic, strong) UILabel *warnLab;
@property (nonatomic, strong) UILabel *noteLab;
@property (nonatomic, strong) UIView *flashlightView;

@property (nonatomic) CGRect qrScanArea;
@property (nonatomic) NSString *qrScanLineImageName;

@end

@implementation BTQRScannerViewController

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navView.backgroundColor = [UIColor BTPrimaryColor];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.session startRunning];
    [self.scanView startAnimation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
    [self.scanView stopAnimation];
}

- (IBAction)cancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)galleryButtonPressed:(UIButton *)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.navigationBar.tintColor = [UIColor BTBlackColor];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark -

- (void)startScan {
    [self.session startRunning];
}

- (void)stopScan {
    [self.session stopRunning];
}

#pragma mark - 

- (void)setUpUI {
    self.qrScanArea = CGRectMake(40, 120, self.view.width-80, self.view.width-80);
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.inputDevice error:&error];
    if (!input) return;
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    if ([self.inputDevice lockForConfiguration:&error]) {
        [self.inputDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        if (self.inputDevice.torchAvailable)
            [self.inputDevice setTorchMode:AVCaptureTorchModeAuto];
        [self.inputDevice unlockForConfiguration];
    }
    [self.session setSessionPreset:AVCaptureSessionPreset1920x1080];
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.layer.bounds;
    [[NSNotificationCenter defaultCenter]addObserverForName:AVCaptureInputPortFormatDescriptionDidChangeNotification object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification * _Nonnull note) {
        output.rectOfInterest = [layer metadataOutputRectOfInterestForRect:self.qrScanArea];
    }];
    [self.view.layer insertSublayer:layer atIndex:0];
    [self.view insertSubview:self.spinner atIndex:1];
    if (self.inputDevice.torchAvailable)
        [self.view insertSubview:self.flashlightView atIndex:1];
    [self.view insertSubview:self.warnView atIndex:1];
    [self.view insertSubview:self.noteLab atIndex:1];
    [self.view insertSubview:self.scanView atIndex:1];
    self.warnView.hidden = YES;
    [self.spinner startAnimating];
}

#pragma mark - 

- (MMScanerLayerView *)scanView {
    if (!_scanView) {
        _scanView = [[MMScanerLayerView alloc] initWithFrame:self.view.bounds];
        _scanView.qrScanArea = self.qrScanArea;
        _scanView.qrScanLayerBorderColor = [UIColor BTSecondaryColor];;
        _scanView.qrScanLineAnimateDuration = 1;
        _scanView.qrScanLineImageName = self.qrScanLineImageName;
        _scanView.contentMode = UIViewContentModeRedraw;
        _scanView.backgroundColor = [UIColor clearColor];
    }
    return _scanView;
}

- (AVCaptureDevice *)inputDevice {
    if (!_inputDevice)  _inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return _inputDevice;
}

- (AVCaptureSession *)session {
    if (!_session) _session = [[AVCaptureSession alloc] init];
    return _session;
}

- (UIActivityIndicatorView *)spinner {
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinner.center = CGPointMake(self.qrScanArea.origin.x+self.qrScanArea.size.width/2, self.qrScanArea.origin.y+self.qrScanArea.size.height/2);
    }
    return _spinner;
}

- (UIView *)warnView {
    if (!_warnView) {
        _warnView = [[UIView alloc] initWithFrame:self.view.bounds];
        _warnView.backgroundColor = [UIColor BTBlackColor];
        _warnView.alpha = 0.7;
        _warnView.userInteractionEnabled = YES;
        [_warnView addSubview:self.warnLab];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureResponse)];
        [_warnView addGestureRecognizer:tapGestureRecognizer];
    }
    return _warnView;
}

- (UILabel *)warnLab {
    if (!_warnLab) {
        _warnLab = [[UILabel alloc] initWithFrame:self.qrScanArea];
        _warnLab.numberOfLines = 0;
        _warnLab.font = [UIFont systemFontOfSize:12.0];
        _warnLab.textColor = [UIColor whiteColor];
        _warnLab.backgroundColor = [UIColor clearColor];
        NSString *warnStr = @"No QR code found\ntap to continue";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:warnStr];
        NSMutableParagraphStyle *stype = [[NSMutableParagraphStyle alloc] init];
        stype.lineSpacing = 3;
        stype.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName value:stype range:NSMakeRange(0,[warnStr length])];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17.0] range:NSMakeRange(0,warnStr.length-15)];
        _warnLab.attributedText = attributedString;
    }
    return _warnLab;
}

- (UILabel *)noteLab {
    if (!_noteLab) {
        _noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.qrScanArea.origin.y+self.qrScanArea.size.height+10, self.view.width, 20)];
        _noteLab.textColor = [UIColor BTGrayColor];
        _noteLab.text = @"Center your Bench Tracker QR code here";
        _noteLab.textAlignment = NSTextAlignmentCenter;
        _noteLab.backgroundColor = [UIColor clearColor];
        _noteLab.font = [UIFont systemFontOfSize:12.0];
    }
    return _noteLab;
}

- (UIView *)flashlightView {
    if (!_flashlightView) {
        _flashlightView = [[UIView alloc] initWithFrame:CGRectMake(0, self.noteLab.bottom+10, self.view.width, 80)];
        _flashlightView.backgroundColor = [UIColor clearColor];
        UIButton *flashBtn = [[UIButton alloc] initWithFrame:CGRectMake((_flashlightView.width-60)/2, 0, 60, 60)];
        [flashBtn setImage:[UIImage imageNamed:@"Flashlight"] forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(flashClicked) forControlEvents:UIControlEventTouchUpInside];
        [_flashlightView addSubview:flashBtn];
        UILabel *noteLab = [[UILabel alloc] initWithFrame:CGRectMake(0, flashBtn.bottom, _flashlightView.width, 20)];
        noteLab.textColor = [UIColor whiteColor];
        noteLab.text = @"Toggle flashlight";
        noteLab.textAlignment = NSTextAlignmentCenter;
        noteLab.backgroundColor = [UIColor clearColor];
        noteLab.font = [UIFont systemFontOfSize:13.0 weight:UIFontWeightMedium];
        [_flashlightView addSubview:noteLab];
    }
    return _flashlightView;
}

#pragma mark -
- (void)flashClicked {
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

#pragma mark -
- (void)gestureResponse {
    self.warnView.hidden = YES;
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if ([features count]) {
        self.warnView.hidden = YES;
        CIQRCodeFeature *feature = [features objectAtIndex:0];
        NSString *scanConetent = feature.messageString;
        //[self.delegate qrScannerVC:self didDismissWithScannedString:scanConetent];
        [self stopScan];
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate qrScannerVC:self didDismissWithScannedString:scanConetent];
        }];
    } else self.warnView.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjects delegate

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        self.warnView.hidden = YES;
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *scanConetent = metadataObject.stringValue;
        //[self.delegate qrScannerVC:self didDismissWithScannedString:scanConetent];
        [self.session stopRunning];
        [self dismissViewControllerAnimated:YES completion:^{
            [BTAchievement markAchievementComplete:ACHIEVEMENT_SCAN animated:YES];
            [self.delegate qrScannerVC:self didDismissWithScannedString:scanConetent];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
