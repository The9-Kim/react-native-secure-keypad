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

@implementation SecureKeypad {
    RCTPromiseResolveBlock resolver;
    RCTPromiseRejectBlock rejecter;
    
    NSInteger gMaxLength;
    NSString *gStrCookie;
    NSString *gHashUrl;
    NSString *gMethod;
    NSString *gLabelText;
    NSString *gKpdType;
    // NSString *gRequestUrl;
    
    
    NSMutableDictionary *gDictParseData;
    NSArray *gSegmentArray;
};

RCT_EXPORT_MODULE()

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_REMAP_METHOD(show,
                 showWithUrl:(nonnull NSString*) url
                 maxLength:(NSInteger) maxLength
                 labelText:(nonnull NSString*) labelText
                 isNeedNewHash: (BOOL)isNeedNewHash
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolver = resolve;
    rejecter = reject;
    
    gMaxLength = maxLength;
    gHashUrl = url;
    gMethod = @"json";
    gKpdType = @"11";
    gLabelText = labelText;
    // NSLog(@"isNeedNewHash : %@", (isNeedNewHash ? @"YES" : @"NO"));

    if ( isNeedNewHash ) {
        gDictParseData = [[NSMutableDictionary alloc] init];
        [self requestSecuKeypadHash];
    } else {
        [self callKeypad];
    }
}

RCT_REMAP_METHOD(request,
                 requestWithUrl:(nonnull NSString*) url
                 bodyJsonStr:(nonnull NSString*) bodyJsonStr
                 token:(nonnull NSString*) token
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject)
{
    resolver = resolve;
    rejecter = reject;
    
    // gRequestUrl = url;
    gDictParseData = [[NSMutableDictionary alloc] init];
    [self requestWithUrl:url andBodyJson:bodyJsonStr andToken:token];
}

- (void)requestWithUrl:(NSString *)urlStr andBodyJson:(NSString *) bodyJsonStr andToken:(NSString *) token
{
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request addValue:gStrCookie forHTTPHeaderField:@"Cookie"];
    [request addValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *bodyObject = [bodyJsonStr objectFromJSONString];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyObject
                                                       options:0
                                                         error:&error];
    [request setHTTPBody:jsonData];
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 30 * 1000;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:nil];
    
    //    NSHTTPURLResponse *response = NULL;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            if ( self->rejecter ) {
                self->rejecter([NSString stringWithFormat:@"%ld", (long)[error code]], [error localizedDescription], error);
                self->rejecter = nil;
                self->resolver = nil;
            }
            return;
        }
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self didRequestDataReceiveFinished:jsonString setCookie:self->gStrCookie];
            //            NSLog(@"response :: %@", jsonData);
            //            NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
            //            NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
            //            NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response textEncodingName]);
        }
        
    }];
    [task resume];
    
    
    //    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //    YHDBHTTPRequest *httpRequest = [[YHDBHTTPRequest alloc] init];
    //
    ////    NSDictionary *bodyObject = [bodyJsonStr objectFromJSONString];
    //    NSData *jsonData = [bodyJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSError *e;
    //    NSDictionary *bodyObject = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    //
    //    NSMutableDictionary *newObject = [[NSMutableDictionary alloc] initWithDictionary:bodyObject];
    ////    [newObject setValue:[bodyObject objectForKey:@"di"] forKey:@"hValue"];
    //    [newObject setValue:gKpdType forKey:@"kpdType"];
    //    [newObject setValue:gMethod forKey:@"method"];
    //
    //    NSMutableDictionary *headObject = [[NSMutableDictionary alloc] init];
    //    [headObject setValue:[NSString stringWithFormat:@"Bearer %@", token] forKey:@"Authorization"];
    //    [headObject setValue:gStrCookie forKey:@"Cookie"];
    //    [headObject setValue:@"application/json" forKey:@"Accept"];
    //    [headObject setValue:@"application/json; charset=UTF-8" forKey:@"Content-Type"];
    //
    //    NSLog(@"requestUrl :: %@", url);
    //    NSLog(@"newObject :: %@", newObject);
    //    NSLog(@"headObject :: %@", headObject);
    //    NSLog(@"Cookie :: %@", gStrCookie);
    //
    //    [httpRequest setDelegate:self selector:@selector(didRequestDataReceiveFinished:setCookie:) errTarget:self errSelector:@selector(didRequestDataReceiveWithError:errDesc:)];
    //    [httpRequest requestUrl:url bodyObject:newObject headObject:headObject];
}

- (void)requestSecuKeypadHash
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    YHDBHTTPRequest *httpRequest = [[YHDBHTTPRequest alloc] init];
    NSDictionary *bodyObject = [NSDictionary dictionaryWithObjectsAndKeys:gMethod, @"method", gKpdType, @"kpdType", nil];
    [httpRequest setDelegate:self selector:@selector(didKeypadRequestDataReceiveFinished:setCookie:) errTarget:self errSelector:@selector(didRequestDataReceiveWithError:errDesc:)];
    [httpRequest requestUrl:gHashUrl bodyObject:bodyObject headObject:nil];
}

- (void)didRequestDataReceiveFinished:(NSString *)result setCookie:(NSString *)cookie
{
    gStrCookie = cookie;
    [self parseRequestDataValue:result];
}

- (void)didRequestDataReceiveWithError:(NSString *)errCode errDesc:(NSString *)errDescription
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSInteger errCodeValue;
    if ([errCode integerValue] < 0) {
        errCodeValue = (-1 * [errCode integerValue]);
    } else {
        errCodeValue = [errCode integerValue];
    }
    
    NSString *errDesc = @"";
    if (errCodeValue == 1004) {
        errDesc = [NSString stringWithFormat:@"[%ld] 서버에 접속할 수 없습니다.\n네트워크 상태를 확인하시기 바랍니다.", (long)errCodeValue];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"서버 접속 오류" message:errDesc delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alertView show];
        
        //버튼 누르기전까지 지연.
        while (alertView.hidden == NO && alertView.superview != nil) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        }
    } else if (errCodeValue == 1001) {
        errDesc = [NSString stringWithFormat:@"[%ld] 요청한 시간이 초과되었습니다.\n잠시 후 이용하시기 바랍니다.", (long)errCodeValue];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"서버 접속 오류" message:errDesc delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alertView show];
        
        //버튼 누르기전까지 지연.
        while (alertView.hidden == NO && alertView.superview != nil) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        }
    } else {
        errDesc = [NSString stringWithFormat:@"[%ld] 알 수 없는 오류가 발생하였습니다.\n잠시 후 이용하시기 바랍니다.", (long)errCodeValue];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"서버 접속 오류" message:errDesc delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        [alertView show];
        
        //버튼 누르기전까지 지연.
        while (alertView.hidden == NO && alertView.superview != nil) {
            [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
        }
    }
    if (rejecter != nil) {
        rejecter([NSString stringWithFormat:@"%ld", (long)errCodeValue], errDesc, nil);
        resolver = nil;
        rejecter = nil;
    }
}


- (void)didKeypadRequestDataReceiveFinished:(NSString *)result setCookie:(NSString *)cookie
{
    if ( cookie != nil ) {
        gStrCookie = cookie;
    }
    [self parseKeypadRequestDataValue:result];
}

- (void)parseRequestDataValue:(NSString *)strValue
{
    NSDictionary *jsonData = [strValue objectFromJSONString];
    NSString *strCode = [jsonData objectForKey:@"code"];
    
    if ([@"0000" isEqualToString:strCode]) {
        if (resolver != nil) {
            resolver(strValue);
        }
    } else {
        if (rejecter != nil) {
            NSString *message = [jsonData objectForKey:@"message"];
            rejecter(strCode, message, nil);
            resolver = nil;
            rejecter = nil;
        }
    }
    
}

- (void)parseKeypadRequestDataValue:(NSString *)strValue
{
    if ([gMethod isEqualToString:@"json"]) {
        NSDictionary *jsonData = [strValue objectFromJSONString];
        NSString *strCode = [jsonData objectForKey:@"code"];
        if ([@"0000" isEqualToString:strCode]) {
            [gDictParseData setDictionary:jsonData];
            [self callKeypad];
        } else {
            NSString *errorMsg = @"";
            if ([@"2001" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 해쉬값 반환 타입을 지정하여야 합니다.";
            } else if ([@"2002" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 지원하지 않는 해쉬값 반환 타입입니다.";
            } else if ([@"2003" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 해쉬값을 생성할 키패드 타입이 필요합니다.";
            } else if ([@"2004" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 동시 생성 가능한 키패드는 최대 2개입니다.";
            } else if ([@"2005" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 해당 키패드는 사용할 수 없는 키패드입니다.";
            } else if ([@"9000" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 서버에 라이선스 파일이 존재하지 않습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9001" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 파일에 라이선스 정보가 누락되어있습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9002" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 정보 복호화에 실패하였습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9003" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 정보가 일치하지 않습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9004" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 만료일이 초과되었습니다. 라이선스 기간 연장이 필요합니다.";
            } else if ([@"9005" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 기간 날짜 형식이 잘못되었습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9006" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 라이선스 검증을 실패하였습니다. 라이선스 파일을 확인바랍니다.";
            } else if ([@"9007" isEqualToString:strCode]) {
                errorMsg = @"[y-SecuKeypad] 허가되지 않은 요청입니다. 헤더 정보를 확인바랍니다.";
            } else {
                errorMsg = @"[y-SecuKeypad] 알 수 없는 오류입니다.";
            }
            if (rejecter != nil) {
                rejecter(strCode, errorMsg, nil);
                resolver = nil;
                rejecter = nil;
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오류" message:errorMsg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
            [alertView show];
        }
    } else {
        YHDBTBXML *tbxml = [YHDBTBXML newYHDBTBXMLWithXMLString:strValue error:nil];
        
        YHDBTBXMLElement *root = tbxml.rootXMLElement;
        if (root) {
            YHDBTBXMLElement *elemCode = [YHDBTBXML childElementNamed:@"code" parentElement:root];
            NSString *strCode = [YHDBTBXML textForElement:elemCode];
            if ([@"0000" isEqualToString:strCode]) {
                [gDictParseData setValue:[YHDBTBXML textForElement:elemCode] forKey:@"code"];
                
                YHDBTBXMLElement *elemMessage = [YHDBTBXML childElementNamed:@"message" parentElement:root];
                [gDictParseData setValue:[YHDBTBXML textForElement:elemMessage] forKey:@"message"];
                
                YHDBTBXMLElement *elemYskHash = [YHDBTBXML childElementNamed:@"yskhash" parentElement:root];
                if (elemYskHash) {
                    [gDictParseData setValue:[YHDBTBXML textForElement:elemYskHash] forKey:@"yskhash"];
                }
                
                YHDBTBXMLElement *elemYskHash1 = [YHDBTBXML childElementNamed:@"yskhash1" parentElement:root];
                if (elemYskHash1) {
                    [gDictParseData setValue:[YHDBTBXML textForElement:elemYskHash1] forKey:@"yskhash1"];
                }
                
                YHDBTBXMLElement *elemYskHash2 = [YHDBTBXML childElementNamed:@"yskhash2" parentElement:root];
                if (elemYskHash2) {
                    [gDictParseData setValue:[YHDBTBXML textForElement:elemYskHash2] forKey:@"yskhash2"];
                }
                [self callKeypad];
            } else {
                NSString *errorMsg = @"";
                if ([@"2001" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 해쉬값 반환 타입을 지정하여야 합니다.";
                } else if ([@"2002" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 지원하지 않는 해쉬값 반환 타입입니다.";
                } else if ([@"2003" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 해쉬값을 생성할 키패드 타입이 필요합니다.";
                } else if ([@"2004" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 동시 생성 가능한 키패드는 최대 2개입니다.";
                } else if ([@"2005" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 해당 키패드는 사용할 수 없는 키패드입니다.";
                } else if ([@"9000" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 서버에 라이선스 파일이 존재하지 않습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9001" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 파일에 라이선스 정보가 누락되어있습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9002" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 정보 복호화에 실패하였습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9003" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 정보가 일치하지 않습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9004" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 만료일이 초과되었습니다. 라이선스 기간 연장이 필요합니다.";
                } else if ([@"9005" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 기간 날짜 형식이 잘못되었습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9006" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 라이선스 검증을 실패하였습니다. 라이선스 파일을 확인바랍니다.";
                } else if ([@"9007" isEqualToString:strCode]) {
                    errorMsg = @"[y-SecuKeypad] 허가되지 않은 요청입니다. 헤더 정보를 확인바랍니다.";
                } else {
                    errorMsg = @"[y-SecuKeypad] 알 수 없는 오류입니다.";
                }
                if (rejecter != nil) {
                    rejecter(strCode, errorMsg, nil);
                    resolver = nil;
                    rejecter = nil;
                }
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"오류" message:errorMsg delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
                [alertView show];
            }
        }
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark y-SecuKeypad delegate
/* 가상키패드 호출 이벤트 처리 함수 */
- (void)callKeypad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *yskHash = [self->gDictParseData objectForKey:@"yskhash"];
        // NSString *dicStr = [NSString stringWithFormat:@"my dictionary is %@", gDictParseData];
        // NSLog(@"%@", dicStr);
        if (yskHash == nil || [yskHash isEqualToString:@""]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"키패드 호출 오류" message:@"키패드 구성에 필요한 값이 누락되었습니다.\n페이지를 새로고침 후 다시 실행하시기 바랍니다." delegate:nil cancelButtonTitle: @"확인" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        YskNumberPadActivityViewController *yskNumberPadActivityViewController = [[YskNumberPadActivityViewController alloc] init];
        [yskNumberPadActivityViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        
        //        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"13.0")) {
        //        }
        [yskNumberPadActivityViewController setDelegate:self];
        [yskNumberPadActivityViewController setOrientationDelegate:self];
        [yskNumberPadActivityViewController setYskHash:[self->gDictParseData objectForKey:@"yskhash"]];
        [yskNumberPadActivityViewController setLabelText:self->gLabelText];
        [yskNumberPadActivityViewController setIsLandScape:YES];
        [yskNumberPadActivityViewController setMaxLength:self->gMaxLength];
        [yskNumberPadActivityViewController setIsSecureString:YES];
        
        UINavigationController *keypadNavigator = [[UINavigationController alloc] initWithRootViewController:yskNumberPadActivityViewController];
        
        [keypadNavigator setNavigationBarHidden:YES];
        [keypadNavigator setModalPresentationStyle:UIModalPresentationFullScreen];
        //        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        //        [appDelegate.window.rootViewController setModalPresentationStyle:UIModalPresentationFullScreen];
        [[keypadNavigator view] setBackgroundColor:[UIColor colorWithRed:243.0f/255.0f green:243.0f/255.0f blue:243.0f/255.0f alpha:1.0]];
        //        NSLog(@"currentViewController :: %@", currentViewController);
        
//        double delayInSeconds = 0.5;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            UIViewController *currentViewController = [self topViewController];
            [currentViewController presentViewController:keypadNavigator animated:NO completion:nil];
//        });
    });
    
    //    [self presentViewController:yskNumberPadActivityViewController animated:YES completion:nil];
}
/* 가상키패드 호출 이벤트 처리 함수 */

/* 가상키패드 입력값 반환 이벤트 처리 함수 */
- (void)onCloseWithRetValue:(NSString *)inputValue setHashValue:(NSString *)hashValue
{
    // NSLog(@"inputValue :: %@", inputValue);
    // NSLog(@"hashValue :: %@", hashValue);
    double delayInSeconds = 0.5;

    @try {
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setValue:inputValue forKey:@"inputValue"];
        [jsonDic setValue:hashValue forKey:@"inputHash"];
        NSError *err;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:0 error:&err];
        NSString *jsonDicStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
//        NSLog(@"%@", jsonDicStr);
        if (resolver != nil) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self->resolver(jsonDicStr);
                self->resolver = nil;
                self->rejecter = nil;
            });
        }
        
    }
    @catch (NSException * e) {
        NSMutableDictionary *jsonDic = [[NSMutableDictionary alloc] init];
        [jsonDic setValue:inputValue forKey:@"inputValue"];
        [jsonDic setValue:hashValue forKey:@"inputHash"];
        
        if (rejecter != nil) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self->rejecter(@"", [e reason], nil);
                self->resolver = nil;
                self->rejecter = nil;
            });
        }
        // NSLog(@"Error: %@%@", [e name], [e reason]);
    }
    @finally {
//        resolver = nil;
//        rejecter = nil;
    }
}
/* 가상키패드 입력값 반환 이벤트 처리 함수 */

- (UIViewController *)topViewController{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [appDelegate.window.rootViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    
    return [self topViewController:appDelegate.window.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
