//
//  CommonUtil.h
//  공통 유틸 헤더 파일
//
//  Created by 박준오 on 13. 10. 4..
//  Copyright (c) 2013년 (주)YH데이타베이스. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YSecuKeypadDelegate <NSObject>
- (void)onCloseWithRetValue:(NSString *)inputValue setHashValue:(NSString *)hashValue;
@end

@interface CommonUtil : NSObject
/* RGB From Hex 함수 */
+ (UIColor *)RGBfromHex:(NSString *)code;
/* RGB From Hex 함수 */

/* 문자열 trim 함수 */
+ (NSString *)trimString:(NSString*) string;
/* 문자열 trim 함수 */

/* Hash값에 생성에 사용된 키값을 hex값으로 디코딩 함수 */
+ (NSMutableArray *)hexDecode:(NSString *)keyValue;
/* Hash값에 생성에 사용된 키값을 hex값으로 디코딩 함수 */

/* 글자 길이에 따른 높이 계산 함수 */
+ (float)calculateHeightOfTextFromWidth:(NSString*)text withFont:(UIFont*)withFont withWidth:(float)width withMode:(NSLineBreakMode)lineBreakMode;
/* 글자 길이에 따른 높이 계산 함수 */
@end
