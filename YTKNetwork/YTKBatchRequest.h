//
//  BatchRequest.h
//  Ape_uni
//
//  Created by TangQiao on 13-9-3.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKRequest.h"

@class YTKBatchRequest;
@protocol YTKBatchRequestDelegate <NSObject>

- (void)batchRequestFinished:(YTKBatchRequest *)batchRequest;

- (void)batchRequestFailed:(YTKBatchRequest *)batchRequest;

@end

@interface YTKBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (weak, nonatomic) id<YTKBatchRequestDelegate> delegate;

@property (nonatomic, copy) void (^successCompletionBlock)(YTKBatchRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(YTKBatchRequest *);

@property (nonatomic) NSInteger tag;

// the animating view
@property (nonatomic, weak) UIView *animatingView;

// the animating text
@property (nonatomic, strong) NSString *animatingText;

- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;

// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                                    failure:(void (^)(YTKBatchRequest *batchRequest))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                              failure:(void (^)(YTKBatchRequest *batchRequest))failure;

// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

@end
