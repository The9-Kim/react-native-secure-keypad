#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AppDelegate.h"

#import <YSecuKeypadSDK/CommonUtil.h>
#import <YSecuKeypadSDK/YHDBHTTPRequest.h>
#import <YSecuKeypadSDK/YHDBJSONKit.h>
#import <YSecuKeypadSDK/YHDBTBXML+HTTP.h>
#import <YSecuKeypadSDK/YskNumberPadActivityViewController.h>

@interface SecureKeypad : NSObject <RCTBridgeModule, YSecuKeypadDelegate>
@end

@implementation SecureKeypad

RCT_EXPORT_MODULE(SecureKeypad)

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (UIView *)view
{
    return [[UIView alloc] init];
}

//RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIView)
//{
//  [view setBackgroundColor:[self hexStringToColor:json]];
//}

RCT_REMAP_METHOD(show,
                 showWithUrl:(nonnull NSString*) url maxLength:(NSInteger) maxLength labelText:(nonnull NSString*) labelText isNeedNewHash: (BOOL)isNeedNewHash
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        resolve(@"");
//        UINavigationController *keypadNavigator = [[UINavigationController alloc] initWithRootViewController:picker];
//        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        [delegate.window.rootViewController presentViewController:keypadNavigator animated:NO completion:nil];
    });

    
//    resolve(result);
}

- (void)requestSecuKeypadHash
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    YHDBHTTPRequest *httpRequest = [[YHDBHTTPRequest alloc] init];
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:@"json", @"method", @"11", @"kpdType", nil];
    [httpRequest setDelegate:self selector:@selector(didRequestDataReceiveFinished:setCookie:) errTarget:self errSelector:@selector(didRequestDataReceiveWithError:errDesc:)];
    [httpRequest requestUrl:@"FIXME::해쉬값을 요청할 URL" bodyObject:bodyObject headObject:nil];
}
/* 가상키패드에서 사용할 해쉬값 요청 함수 */

/* 가상키패드에서 사용할 해쉬값 요청 결과 처리 함수 */
- (void)didRequestDataReceiveFinished:(NSString *)result setCookie:(NSString *)cookie
{
//    self.strCookie = cookie;
    [self parseRequestDataValue:result];
}
/* 가상키패드에서 사용할 해쉬값 요청 결과 처리 함수 */

/* 가상키패드에서 사용할 해쉬값 요청 정보 파싱 함수 */
- (void)parseRequestDataValue:(NSString *)strValue
{
//    if ([self.method isEqualToString:@"json"]) {
//        NSDictionary *jsonData = [strValue objectFromJSONString];
//        NSString *strCode = [jsonData objectForKey:@"code"];
//        if ([@"0000" isEqualToString:strCode]) {
//            [self.dictParseData setDictionary:jsonData];
//        } else {
//            NSString *errorMsg = @"";
//            if ([@"2001" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 해쉬값 반환 타입을 지정하여야 합니다.";
//            } else if ([@"2002" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 지원하지 않는 해쉬값 반환 타입입니다.";
//            } else if ([@"2003" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 해쉬값을 생성할 키패드 타입이 필요합니다.";
//            } else if ([@"2004" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 동시 생성 가능한 키패드는 최대 2개입니다.";
//            } else if ([@"2005" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 해당 키패드는 사용할 수 없는 키패드입니다.";
//            } else if ([@"9000" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 서버에 라이선스 파일이 존재하지 않습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9001" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 파일에 라이선스 정보가 누락되어있습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9002" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 정보 복호화에 실패하였습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9003" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 정보가 일치하지 않습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9004" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 만료일이 초과되었습니다. 라이선스 기간 연장이 필요합니다.";
//            } else if ([@"9005" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 기간 날짜 형식이 잘못되었습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9006" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 라이선스 검증을 실패하였습니다. 라이선스 파일을 확인바랍니다.";
//            } else if ([@"9007" isEqualToString:strCode]) {
//                errorMsg = @"[y-SecuKeypad] 허가되지 않은 요청입니다. 헤더 정보를 확인바랍니다.";
//            } else {
//                errorMsg = @"[y-SecuKeypad] 알 수 없는 오류입니다.";
//            }
//
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오류" message:errorMsg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
//            [alertView show];
//        }
//    }
//
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}
@end
