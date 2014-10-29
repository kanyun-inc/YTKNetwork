//
//  BatchRequest.m
//  Ape_uni
//
//  Created by TangQiao on 13-9-3.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import "YTKBatchRequest.h"
#import "YTKNetworkPrivate.h"

@interface YTKBatchRequest() <YTKRequestDelegate>

@property (nonatomic) NSInteger finishedCount;

@end

@implementation YTKBatchRequest

- (id)initWithRequestArray:(NSArray *)requestArray {
    self = [super init];
    if (self) {
        _requestArray = [requestArray copy];
        _finishedCount = 0;
        for (YTKRequest * req in _requestArray) {
            if (![req isKindOfClass:[YTKRequest class]]) {
                YTKLog(@"Error, request item must be YTKRequest instance.");
                return nil;
            }
        }
    }
    return self;
}

- (void)start {
//    [self showAnimating];
    for (YTKRequest * req in _requestArray) {
        req.delegate = self;
//        if (self.animatingView) {
//            // clear subrequests animating view if batch request has set the animating view
//            req.animatingView = nil;
//        }
        [req start];
    }
}

- (void)stop {
//    [self hideAnimating];
    _delegate = nil;
    [self clearRequest];
}

- (void)startWithCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                                    failure:(void (^)(YTKBatchRequest *batchRequest))failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                              failure:(void (^)(YTKBatchRequest *batchRequest))failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

- (BOOL)isDataFromCache {
    BOOL result = YES;
    for (YTKRequest *request in _requestArray) {
        if (!request.isDataFromCache) {
            result = NO;
        }
    }
    return result;
}


- (void)dealloc {
    [self clearRequest];
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(YTKRequest *)request {
    _finishedCount++;
    if (_finishedCount == _requestArray.count) {
//        [self hideAnimating];
        if ([_delegate respondsToSelector:@selector(batchRequestFinished:)]) {
            [_delegate batchRequestFinished:self];
        }
        if (_successCompletionBlock) {
            _successCompletionBlock(self);
        }
        [self clearCompletionBlock];
    }
}

- (void)requestFailed:(YTKRequest *)request {
    [self clearRequest];
    if ([_delegate respondsToSelector:@selector(batchRequestFailed:)]) {
//        [self hideAnimating];
        [_delegate batchRequestFailed:self];
    }
    if (_failureCompletionBlock) {
        _failureCompletionBlock(self);
    }
    [self clearCompletionBlock];
}

- (void)clearRequest {
//    [self hideAnimating];
    for (YTKRequest * req in _requestArray) {
        [req stop];
    }
    [self clearCompletionBlock];
}

#pragma mark - Animating

//- (void)showAnimating {
//    if (_animatingView != nil) {
//        [YTKAlertUtils showLoadingAlertView:_animatingText inView:_animatingView];
//    }
//}
//
//- (void)hideAnimating {
//    if (self.animatingView != nil) {
//        [YTKAlertUtils hideLoadingAlertView:_animatingView];
//    }
//}

@end
