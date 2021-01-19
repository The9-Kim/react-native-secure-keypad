//
//  TBXML+HTTP.h
//
//  Created by Tom Bradley on 29/01/2011.
//  Copyright 2012 71Squared All rights reserved.
//

#import "YHDBTBXML.h"

typedef void (^YHDBTBXMLAsyncRequestSuccessBlock)(NSData *,NSURLResponse *);
typedef void (^YHDBTBXMLAsyncRequestFailureBlock)(NSData *,NSError *);

@interface NSMutableURLRequest (YHDBTBXML_HTTP)

+ (NSMutableURLRequest*) tbxmlGetRequestWithURL:(NSURL*)url;
+ (NSMutableURLRequest*) tbxmlPostRequestWithURL:(NSURL*)url parameters:(NSDictionary*)parameters;

@end


@interface NSURLConnection (YHDBTBXML_HTTP)

+ (void)tbxmlAsyncRequest:(NSURLRequest *)request success:(YHDBTBXMLAsyncRequestSuccessBlock)successBlock failure:(YHDBTBXMLAsyncRequestFailureBlock)failureBlock;

@end


@interface YHDBTBXML (YHDBTBXML_HTTP)

+ (id)newYHDBTBXMLWithURL:(NSURL*)aURL success:(YHDBTBXMLSuccessBlock)successBlock failure:(YHDBTBXMLFailureBlock)failureBlock;
- (id)initWithURL:(NSURL*)aURL success:(YHDBTBXMLSuccessBlock)successBlock failure:(YHDBTBXMLFailureBlock)failureBlock;

@end


