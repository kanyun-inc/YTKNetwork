//
//  ChainRequest.h
//  Ape_uni
//
//  Created by TangQiao on 13-10-30.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"

@class YTKChainRequest;
@protocol YTKChainRequestDelegate <NSObject>

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest;

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request;

@end

typedef void (^ChainCallback)(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest);

@interface YTKChainRequest : NSObject

@property (weak, nonatomic) id<YTKChainRequestDelegate> delegate;

// the animating view
@property (nonatomic, weak) UIView * animatingView;

// the animating text
@property (nonatomic, strong) NSString * animatingText;

// start chain request
- (void)start;

// stop chain request
- (void)stop;

- (void)addRequest:(YTKBaseRequest *)request callback:(ChainCallback)callback;

- (NSArray *)requestArray;

@end
