//
//  YTKNetworkConfig.h
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

NS_ASSUME_NONNULL_BEGIN

@class AFSecurityPolicy;

@protocol YTKUrlFilterProtocol <NSObject>
- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request;
@end

@protocol YTKCacheDirPathFilterProtocol <NSObject>
- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(YTKBaseRequest *)request;
@end

@interface YTKNetworkConfig : NSObject

+ (YTKNetworkConfig *)sharedInstance;

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *cdnUrl;
@property (strong, nonatomic, readonly) NSArray<id<YTKUrlFilterProtocol>> *urlFilters;
@property (strong, nonatomic, readonly) NSArray<id<YTKCacheDirPathFilterProtocol>> *cacheDirPathFilters;
@property (strong, nonatomic) AFSecurityPolicy *securityPolicy;

- (void)addUrlFilter:(id<YTKUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id<YTKCacheDirPathFilterProtocol>)filter;

@end

NS_ASSUME_NONNULL_END
