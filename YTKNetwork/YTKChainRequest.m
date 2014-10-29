//
//  ChainRequest.m
//  Ape_uni
//
//  Created by TangQiao on 13-10-30.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import "YTKChainRequest.h"
#import "YTKChainRequestAgent.h"
#import "YTKNetworkPrivate.h"

@interface YTKChainRequest()<YTKRequestDelegate>

@property (strong, nonatomic) NSMutableArray *requestArray;
@property (strong, nonatomic) NSMutableArray *requestCallbackArray;
@property (assign, nonatomic) NSUInteger nextRequestIndex;
@property (strong, nonatomic) ChainCallback emptyCallback;

@end

@implementation YTKChainRequest

- (id)init {
    self = [super init];
    if (self) {
        _nextRequestIndex = 0;
        _requestArray = [NSMutableArray array];
        _requestCallbackArray = [NSMutableArray array];
        _emptyCallback = ^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
            // do nothing
        };
    }
    return self;
}

- (void)start {
    if (_nextRequestIndex > 0) {
        YTKLog(@"Error! Chain request has already started.");
        return;
    }

    if ([_requestArray count] > 0) {
//        [self showAnimating];
        [self startNextRequest];
        [[YTKChainRequestAgent sharedInstance] addChainRequest:self];
    } else {
        YTKLog(@"Error! China request array is empty.");
    }
}

- (void)stop {
    [self clearRequest];
//    [self hideAnimating];
    [[YTKChainRequestAgent sharedInstance] removeChainRequest:self];
}

- (void)addRequest:(YTKBaseRequest *)request callback:(ChainCallback)callback {
    [_requestArray addObject:request];
    if (callback != nil) {
        [_requestCallbackArray addObject:callback];
    } else {
        [_requestCallbackArray addObject:_emptyCallback];
    }
}

- (NSArray *)requestArray {
    return _requestArray;
}

- (BOOL)startNextRequest {
    if (_nextRequestIndex < [_requestArray count]) {
        YTKBaseRequest *request = _requestArray[_nextRequestIndex];
        _nextRequestIndex++;
        request.delegate = self;
        [request start];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Network Request Delegate

- (void)requestFinished:(YTKBaseRequest *)request {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    ChainCallback callback = _requestCallbackArray[currentRequestIndex];
    callback(self, request);
    if (![self startNextRequest]) {
//        [self hideAnimating];
        if ([_delegate respondsToSelector:@selector(chainRequestFinished:)]) {
            [_delegate chainRequestFinished:self];
            [[YTKChainRequestAgent sharedInstance] removeChainRequest:self];
        }
    }
}

- (void)requestFailed:(YTKBaseRequest *)request {
//    [self hideAnimating];
    if ([_delegate respondsToSelector:@selector(chainRequestFailed:failedBaseRequest:)]) {
        [_delegate chainRequestFailed:self failedBaseRequest:request];
        [[YTKChainRequestAgent sharedInstance] removeChainRequest:self];
    }
}

- (void)clearRequest {
    NSUInteger currentRequestIndex = _nextRequestIndex - 1;
    if (currentRequestIndex < [_requestArray count]) {
        YTKBaseRequest *request = _requestArray[currentRequestIndex];
        [request stop];
    }
    [_requestArray removeAllObjects];
    [_requestCallbackArray removeAllObjects];
}


#pragma mark - Animating

//- (void)showAnimating {
//    if (_animatingView != nil) {
//        [YTKAlertUtils showLoadingAlertView:_animatingText inView:_animatingView];
//    }
//}
//
//- (void)hideAnimating {
//    if (_animatingView != nil) {
//        [YTKAlertUtils hideLoadingAlertView:_animatingView];
//    }
//}

@end
