//
//  AKCodeReader.m
//  QRCodeScane
//
//  Created by qiang on 9/6/16.
//  Copyright © 2016 akite. All rights reserved.
//
@import UIKit;
@import CoreImage;
@import AVFoundation;
@import AudioToolbox;

#import "AKCodeReader.h"

@interface AKCodeReader () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;

@end



@implementation AKCodeReader

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [[AVCaptureSession alloc] init];
        _devicePostion = AVCaptureDevicePositionBack;
    }
    return self;
}

#pragma mark - property
- (void)setDevicePostion:(NSInteger)devicePostion
{
    if (_devicePostion == devicePostion) return;
    _devicePostion = devicePostion;
    self.device = [AKCodeReader deviceInputWithType:AVMediaTypeVideo andDevicePostion:devicePostion];
    NSError *error;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    [self.session beginConfiguration];
    [self.session removeInput:self.input];
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
        self.input = deviceInput;
    }
    [self.session commitConfiguration];
    
}

- (void)configure
{
    if (self.session == nil) {
        NSLog(@"current session is nil");
        return;
    }
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device
                                                       error:&error];
    if (!self.input) {
        NSLog(@"Could not create video device input: %@", error);
    }
    
    [self.session beginConfiguration];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    if ([self.session canAddOutput:output]) {
        [self.session addOutput:output];
        self.output = output;
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        NSLog(@"available type : %@", [output availableMetadataObjectTypes]);
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    [self.session commitConfiguration];
}

- (void)setRectOfInterest:(CGRect)rect
{
//        [self.session beginConfiguration];
    self.output.rectOfInterest = rect;
}

#pragma mark - capture output delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count>0) {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0];
        // 播放扫描二维码的声音
        NSString *path = [[NSBundle mainBundle] pathForResource:@"ScanSuccess" ofType:@"mp3"];
        NSURL *url = [NSURL fileURLWithPath:path];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
        
        AudioServicesPlaySystemSound(soundID);
        
        if (self.captureCode) {
            self.captureCode(metadataObject.stringValue);
        }
    }
}

- (void)startRunning
{
    [self.session startRunning];
}

- (BOOL)isRunning
{
    return [self.session isRunning];
}

- (void)stopRunning
{
    [self.session stopRunning];
}

#pragma mark - class method
+ (AVCaptureDevice *)deviceInputWithType:(NSString *)type andDevicePostion:(NSInteger)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:type];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}


@end
