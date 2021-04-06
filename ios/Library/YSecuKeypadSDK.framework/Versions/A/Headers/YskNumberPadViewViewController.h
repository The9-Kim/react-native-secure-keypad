//
//  YskNumberPadViewViewController.h
//  y-SecuKeypad Number형 키패드 View 형태 View Controller 헤더 파일
//
//  Created by 박준오 on 14. 1. 10..
//  Copyright (c) 2014년 YHDatabase Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonUtil.h"

@protocol NumberViewOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

@interface YskNumberPadViewViewController : UIViewController <UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) id orientationDelegate;
@property (unsafe_unretained, nonatomic) id <YSecuKeypadDelegate> delegate;
@property (strong, nonatomic) NSString *yskHash;
@property (assign, nonatomic) NSInteger maxLength;
@property (assign, nonatomic) NSInteger minLength;
@property (assign, nonatomic) BOOL isLandScape;
@property (strong, nonatomic) NSString *labelText;
@property (assign, nonatomic) BOOL isSecureString;

@end
