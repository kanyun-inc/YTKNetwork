//
//  YTKBatchRequest.h
//
//  Copyright (c) 2012-2014 YTKNetwork https://github.com/yuantiku
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "YTKRequest.h"

@class YTKBatchRequest;
@protocol YTKBatchRequestDelegate <NSObject>

@optional

- (void)batchRequestFinished:(YTKBatchRequest *)batchRequest;

- (void)batchRequestFailed:(YTKBatchRequest *)batchRequest;

@end

@interface YTKBatchRequest : NSObject

@property (strong, nonatomic, readonly) NSArray *requestArray;

@property (weak, nonatomic) id<YTKBatchRequestDelegate> delegate;

@property (nonatomic, copy) void (^successCompletionBlock)(YTKBatchRequest *);

@property (nonatomic, copy) void (^failureCompletionBlock)(YTKBatchRequest *);

@property (nonatomic) NSInteger tag;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

- (id)initWithRequestArray:(NSArray *)requestArray;

- (void)start;

- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                                    failure:(void (^)(YTKBatchRequest *batchRequest))failure;

- (void)setCompletionBlockWithSuccess:(void (^)(YTKBatchRequest *batchRequest))success
                              failure:(void (^)(YTKBatchRequest *batchRequest))failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

/// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

@end
