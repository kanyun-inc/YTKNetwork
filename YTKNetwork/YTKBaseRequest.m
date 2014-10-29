//
//  FenbiBaseRequest.m
//  Solar
//
//  Created by tangqiao on 8/4/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "YTKBaseRequest.h"
#import "YTKNetworkAgent.h"
#import "YTKAlertUtils.h"

@implementation YTKBaseRequest

/// for subclasses to overwrite
- (void)requestCompleteFilter {
    [self hideAnimating];
}

- (void)requestFailedFilter {
    [self hideAnimating];
}

- (NSString *)requestUrl {
    return EMPTY_STRING;
}

- (NSString *)cdnUrl {
    return EMPTY_STRING;
}

- (NSString *)baseUrl {
    return EMPTY_STRING;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGet;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeHTTP;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)useCDN {
    return NO;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock {
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock {
    return nil;
}

/// append self to request queue
- (void)start {
    [self showAnimating];
    [[YTKNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
    [self hideAnimating];
    self.delegate = nil;
    [[YTKNetworkAgent sharedInstance] cancelRequest:self];
}

- (BOOL)isExecuting {
    return self.requestOperation.isExecuting;
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(YTKBaseRequest *request))success
                                    failure:(void (^)(YTKBaseRequest *request))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(YTKBaseRequest *request))success
                              failure:(void (^)(YTKBaseRequest *request))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (void)showAnimating {
    if (self.animatingView != nil) {
        [YTKAlertUtils showLoadingAlertView:self.animatingText inView:self.animatingView];
    }
}

- (void)hideAnimating {
    if (self.animatingView != nil) {
        [YTKAlertUtils hideLoadingAlertView:self.animatingView];
    }
}

- (id)responseJSONObject {
    return self.requestOperation.responseObject;
}

- (NSString *)responseString {
    return self.requestOperation.responseString;
}

- (NSInteger)responseStatusCode {
    return self.requestOperation.response.statusCode;
}

- (NSDictionary *)responseHeaders {
    return self.requestOperation.response.allHeaderFields;
}

@end
