//
//  FenbiNetworkAgent.h
//  Solar
//
//  Created by tangqiao on 8/4/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"
#import "AFNetworking.h"

@interface YTKNetworkAgent : NSObject

+ (YTKNetworkAgent *)sharedInstance;

- (void)addRequest:(YTKBaseRequest *)request;

- (void)cancelRequest:(YTKBaseRequest *)request;

- (void)cancelAllRequests;

// 根据request和networkConfig构建url
- (NSString *)buildRequestUrl:(YTKBaseRequest *)request;

@end
