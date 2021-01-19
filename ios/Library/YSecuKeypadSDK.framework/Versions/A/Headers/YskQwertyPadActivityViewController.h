//
//  YskQwertyPadActivityViewController.h
//  y-SecuKeypad QWERTY형 키패드 Activity 형태 View Controller 헤더 파일
//
//  Created by 박준오 on 13. 10. 4..
//  Copyright (c) 2013년 YHDatabase Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CommonUtil.h"

@protocol QwertyActivityOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end

@interface YskQwertyPadActivityViewController : UIViewController <UITextFieldDelegate>

@property (unsafe_unretained, nonatomic) id orientationDelegate;
@property (unsafe_unretained, nonatomic) id <YSecuKeypadDelegate> delegate;
@property (strong, nonatomic) NSString *yskHash;
@property (assign, nonatomic) NSInteger maxLength;
@property (assign, nonatomic) BOOL isLandScape;
@property (strong, nonatomic) NSString *labelText;

@end
