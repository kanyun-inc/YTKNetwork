//
//  YTKChainRequest.h
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
#import "YTKBaseRequest.h"

@class YTKChainRequest;
@protocol YTKChainRequestDelegate <NSObject>

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest;

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request;

@end

typedef void (^ChainCallback)(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest);

@interface YTKChainRequest : NSObject

@property (weak, nonatomic) id<YTKChainRequestDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// start chain request
- (void)start;

/// stop chain request
- (void)stop;

- (void)addRequest:(YTKBaseRequest *)request callback:(ChainCallback)callback;

- (NSArray *)requestArray;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<YTKRequestAccessory>)accessory;

@end
