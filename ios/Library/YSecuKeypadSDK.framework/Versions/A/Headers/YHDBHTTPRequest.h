//
//  HTTPRequest.h
//  HTTPRequest
//
//  Created by Woo Ram Park on 09. 04. 03.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YHDBHTTPRequest : NSObject {
	NSMutableData *receivedData;
	NSURLResponse *response;
	NSString *result;
    NSString *cookie;
	id target;
	SEL selector;
	id eTarget;
	SEL eSelector;
}

- (BOOL)requestUrl:(NSString *)url bodyObject:(NSDictionary *)bodyObject headObject:(NSDictionary *)headObject;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)setDelegate:(id)aTarget selector:(SEL)aSelector errTarget:(id)eTarget errSelector:(SEL)eSelector;

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSURLResponse *response;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *cookie;
@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id eTarget;
@property (nonatomic, assign) SEL eSelector;

@end
