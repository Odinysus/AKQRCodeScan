//
//  AKCodeViewController.h
//  QRCodeScane
//
//  Created by qiang on 9/7/16.
//  Copyright © 2016 akite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKCodeReader.h"
typedef void(^CaptureCodeBlock)(NSString *);


@interface AKCodeViewController : UIViewController

@property (nonatomic, strong) AKCodeReader *reader;

@property (nonatomic, strong) CaptureCodeBlock codeBlock;

@property (nonatomic) BOOL hiddenChnageButton;


@property (nonatomic) CGFloat widthOfInterest;

@property (nonatomic) UIButton *backBtn;
@end
