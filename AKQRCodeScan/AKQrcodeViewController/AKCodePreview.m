//
//  AKCodePreview.m
//  QRCodeScane
//
//  Created by qiang on 9/7/16.
//  Copyright © 2016 akite. All rights reserved.
//

#import "AKCodePreview.h"
#import <AVFoundation/AVFoundation.h>

@implementation AKCodePreview

+ (Class)layerClass
{
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    return previewLayer.session;
}

- (void)setSession:(AVCaptureSession *)session
{
    AVCaptureVideoPreviewLayer *previewLayer = (AVCaptureVideoPreviewLayer *)self.layer;
    previewLayer.session = session;
}

@end
