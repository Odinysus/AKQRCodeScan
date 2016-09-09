//
//  AKCodeReader.h
//  QRCodeScane
//
//  Created by qiang on 9/6/16.
//  Copyright © 2016 akite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^CaptureCodeBlock)(NSString *);
@interface AKCodeReader : NSObject

@property (nonatomic, strong) AVCaptureSession *session;

/**
 *  	AVCaptureDevicePositionUnspecified         = 0,
 *      AVCaptureDevicePositionBack                = 1,
 *      AVCaptureDevicePositionFront               = 2
 *      默认是后摄像头
 */
@property (nonatomic) NSInteger devicePostion;
@property (nonatomic, strong) CaptureCodeBlock captureCode;

- (void)configure;
- (BOOL)isRunning;
- (void)startRunning;
- (void)stopRunning;

- (void)setRectOfInterest:(CGRect)rect;


@end
