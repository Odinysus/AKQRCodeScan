//
//  AKCodeViewController.m
//  QRCodeScane
//
//  Created by qiang on 9/7/16.
//  Copyright © 2016 akite. All rights reserved.
//
@import AVFoundation;

#import "AKCodeViewController.h"
#import "AKCodePreview.h"


@interface AKCodeViewController ()

@property (nonatomic, strong) AKCodePreview *preview;

@property (nonatomic, strong) UIButton *cammeraBtn;
@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic) CGRect clipRect;
@property (nonatomic) dispatch_queue_t sessionQueue;

// corner imageview
@property (nonatomic) UIImageView *LeftTopImgView;
@property (nonatomic, strong) UIImageView *rightTopImgView;
@property (nonatomic, strong) UIImageView *leftBottomImgView;
@property (nonatomic, strong) UIImageView *rightBottomImgView;

@property (nonatomic, strong)  UIActivityIndicatorView* activityIndicatorView;
// 当前是否授权
@property (nonatomic) BOOL granted;

@end

@implementation AKCodeViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _widthOfInterest = [UIScreen mainScreen].bounds.size.width * 0.8f;
    }
    return self;
}

- (void)viewDidLoad
{
    self.restorationIdentifier = @"akcodeviewcontroller";
    self.restorationClass = [self class];
    
       CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    // 活动指示器
    
    self.activityIndicatorView = [ [ UIActivityIndicatorView alloc ] initWithFrame:CGRectMake(0,0,50.0f,50.f)];
    self.activityIndicatorView.center = self.view.center;
    self.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.activityIndicatorView.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.preview = [[AKCodePreview alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.preview];
 
    self.sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    self.granted = NO;
    
    // 摄像头授权
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized:
        {
            // 当前已授权,继续使用
            self.granted = YES;
            break;
        }
            case AVAuthorizationStatusNotDetermined:
        {
            // 摄像头的任务队列(session queue)是异步的,为了避免授权过程中对摄像头的影响,暂停任务队列.
            // 代码参考:https://developer.apple.com/library/ios/samplecode/AVCam/Introduction/Intro.html#//apple_ref/doc/uid/DTS40010112
            dispatch_suspend(self.sessionQueue);
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^( BOOL granted ) {
                if (granted) {
                    self.granted = YES;
                }
                
                dispatch_resume( self.sessionQueue );
            }];
            break;
        }
        default:
            break;
    }
    
    // 初始化session,由于调用-[AVCaptureSession startRunning]方法可能需要比较长的时间.所以session得初始化与执行放在异步中执行.
    self.reader = [[AKCodeReader alloc] init];
    self.reader.captureCode = self.codeBlock;
    self.preview.session = self.reader.session;

    CGRect rect = CGRectMake((screenSize.width - self.widthOfInterest)/2,
                             (screenSize.height-self.widthOfInterest)/2,
                             self.widthOfInterest,
                             self.widthOfInterest);
    dispatch_async(self.sessionQueue, ^{
        if (!self.granted)
            return ;
        [self.reader configure];
//        CGRect rect = CGRectMake(0.25, 0.25, 0.75, 0.75);
        
       	dispatch_async( dispatch_get_main_queue(), ^{
            // 在主线程中更新当前的UI
            UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
            AVCaptureVideoOrientation initialVideoOrientation = AVCaptureVideoOrientationPortrait;
            if ( statusBarOrientation != UIInterfaceOrientationUnknown ) {
                initialVideoOrientation = (AVCaptureVideoOrientation)statusBarOrientation;
            }
            
            AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.preview.layer;
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            previewLayer.connection.videoOrientation = initialVideoOrientation;
            CGRect rectOfInterect = [previewLayer metadataOutputRectOfInterestForRect:rect];
            NSLog(@"rect of interest:%@", NSStringFromCGRect(rectOfInterect));
            NSLog(@"rect :%@", NSStringFromCGRect(rect));
            [self.reader setRectOfInterest:rectOfInterect];

        });
    });
    
    [self configureCornerImageViews];
    [self.view addSubview:self.backBtn];
//    self.hiddenChnageButton = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    dispatch_async(self.sessionQueue, ^{
        if (self.granted) {
            [self.reader.session startRunning];
            
//            dispatch_async( dispatch_get_main_queue(), ^{
//            });
   
        } else {
            // 用户更改相机权限,
            dispatch_async( dispatch_get_main_queue(), ^{
                NSString *message = NSLocalizedString( @"请在iPhone的\"-隐私-相机\"选项中,允许APP访问你的相机.", @"Alert message when the user has denied access to the camera" );
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"错误" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"OK", @"Alert OK button" ) style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                // Provide quick access to Settings.
                UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alertController addAction:settingsAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } );
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView removeFromSuperview];
        });
    });
    
   
}

- (void)viewDidDisappear:(BOOL)animated
{
    dispatch_async(self.sessionQueue, ^{
        if (self.granted) {
            [self.reader.session stopRunning];
        } else {
          
        }
    });
    [super viewDidDisappear:animated];
}

- (void)configureCornerImageViews
{
    
    self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
//    self.cameraView.alpha = 0.5;
    self.cameraView.backgroundColor = [UIColor clearColor];

    //中间镂空的矩形框
    self.clipRect = CGRectMake(0, 0, 50, 100);
    //背景大小
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.frame cornerRadius:0];
    //镂空大小
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:self.clipRect];
    [path appendPath:circlePath];
//    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;//中间镂空的关键点 填充规则
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5f;
    self.maskLayer = fillLayer;
    [self.cameraView.layer addSublayer:fillLayer];
  
    [self.view addSubview:self.cameraView];
    
    self.LeftTopImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LeftTopCode"]];
    self.rightTopImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightTopCode"]];
    self.leftBottomImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LeftBottomCode"]];
    self.rightBottomImgView =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightBottomCode"]];
    [self.view addSubview:self.LeftTopImgView];
    [self.view addSubview:self.rightTopImgView];
    [self.view addSubview:self.leftBottomImgView];
    [self.view addSubview:self.rightBottomImgView];
    
    self.widthOfInterest = self.widthOfInterest;
}

- (void)onClickCammera:(UIButton *)btn
{
    dispatch_async(self.sessionQueue, ^{
        if (self.reader.devicePostion == AVCaptureDevicePositionBack) {
            self.reader.devicePostion = AVCaptureDevicePositionFront;
        } else {
            self.reader.devicePostion = AVCaptureDevicePositionBack;
        }
    });
}

#pragma mark - properties
/**
 *  It create camera button when you first call this method
 *
 *  @param hiddenChnageButton
 */
- (void)setHiddenChnageButton:(BOOL)hiddenChnageButton
{
    if (_hiddenChnageButton == hiddenChnageButton) {
        _hiddenChnageButton = hiddenChnageButton;
        self.cammeraBtn.hidden = hiddenChnageButton;
    }
}


- (UIButton *)cammeraBtn
{
    if (_cammeraBtn) return _cammeraBtn;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    _cammeraBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenSize.width - 50, 30, 50, 30)];
    [_cammeraBtn setImage:[UIImage imageNamed:@"SwitchCamera"] forState:UIControlStateNormal];
    [_cammeraBtn addTarget:self action:@selector(onClickCammera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cammeraBtn];
    return _cammeraBtn;
}

- (void)setWidthOfInterest:(CGFloat)widthOfInterest
{
    CGSize size = self.view.frame.size;
    CGFloat imgWidth = 25.f;
    _widthOfInterest = widthOfInterest;
    self.LeftTopImgView.frame = CGRectMake((size.width-widthOfInterest)/2, (size.height-widthOfInterest)/2, imgWidth, imgWidth);
    self.rightTopImgView.frame = CGRectMake((size.width + widthOfInterest)/2-imgWidth, (size.height-widthOfInterest)/2, imgWidth, imgWidth);
    self.leftBottomImgView.frame = CGRectMake((size.width-widthOfInterest)/2, (size.height+widthOfInterest)/2-imgWidth, imgWidth, imgWidth);
    self.rightBottomImgView.frame = CGRectMake((size.width+widthOfInterest)/2-imgWidth, (size.height+widthOfInterest)/2-imgWidth, imgWidth, imgWidth);
//    self.cameraView.frame = CGRectMake((size.width-widthOfInterest)/2, (size.height-widthOfInterest)/2, widthOfInterest, widthOfInterest);
    
    self.clipRect = CGRectMake((size.width-widthOfInterest)/2, (size.height-widthOfInterest)/2, widthOfInterest, widthOfInterest);
    //背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.view.frame cornerRadius:0];
    //镂空
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:self.clipRect];
    [path appendPath:circlePath];
    self.maskLayer.path = path.CGPath;
    //    [path setUsesEvenOddFillRule:YES];
    // 计算实际框大小
    
}

- (UIButton *)backBtn
{
    if (_backBtn) return _backBtn;
    _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 20, 25, 25)];
    [_backBtn setImage:[UIImage imageNamed:@"Back"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(onClickBack:) forControlEvents:UIControlEventTouchUpInside];
    return _backBtn;
}

#pragma mark - action

- (void)onClickBack:(UIButton *)btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
}

@end
