//
//  QIMFilteredProtocol.m
//  QIMCommon
//
//  Created by 李露 on 2018/9/11.
//  Copyright © 2018年 QIMKit. All rights reserved.
//

#import "QIMFilteredProtocol.h"
#import "QIMPrivateHeader.h"
#import "QIMSchemaManager.h"

static NSString * const hasInitKey = @"QIMCustomDataProtocolKey";

@interface QIMFilteredProtocol ()

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *connection;

@end

@implementation QIMFilteredProtocol

+ (void)start {
    [NSURLProtocol registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    //Schema拦截
    NSString *noQueryTempUrl = [NSString stringWithFormat:@"%@://%@%@", request.URL.scheme, request.URL.host, request.URL.path];
    
    if ([[QIMSchemaManager sharedInstance] isLocalSchemaWithUrl:noQueryTempUrl] && ![NSURLProtocol propertyForKey:hasInitKey inRequest:request]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    NSString *url = request.URL.absoluteString;

    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //这边可用干你想干的事情。。更改地址，或者设置里面的请求头。。
    return mutableReqeust;
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //做下标记，防止递归调用
    [NSURLProtocol setProperty:@YES forKey:hasInitKey inRequest:mutableReqeust];

    //Schema拦截
    NSString *noQueryTempUrl = [NSString stringWithFormat:@"%@://%@%@", mutableReqeust.URL.scheme, mutableReqeust.URL.host, mutableReqeust.URL.path];
    
    if ([[QIMSchemaManager sharedInstance] isLocalSchemaWithUrl:noQueryTempUrl]) {
        
        [[QIMSchemaManager sharedInstance] postSchemaNotificationWithUrl:mutableReqeust.URL];
        
        [self.client URLProtocolDidFinishLoading:self];
    }
    else {
        self.connection = [NSURLConnection connectionWithRequest:mutableReqeust delegate:self];
    }
}

- (void)stopLoading {
    [self.connection cancel];
}

#pragma mark- NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [self.client URLProtocol:self didFailWithError:error];
}

#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.responseData = [[NSMutableData alloc] init];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.responseData appendData:data];
    [self.client URLProtocol:self didLoadData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
}

@end
