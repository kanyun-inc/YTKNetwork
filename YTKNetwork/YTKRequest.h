//
//  YTKRequest.h
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

#import "YTKBaseRequest.h"

@interface YTKRequest : YTKBaseRequest

@property (nonatomic) BOOL ignoreCache;

/// 返回当前缓存的对象
- (id)cacheJson;

/// 是否当前的数据从缓存获得
- (BOOL)isDataFromCache;

/// 返回是否当前缓存需要更新
- (BOOL)isCacheVersionExpired;

/// 强制更新缓存
- (void)startWithoutCache;

/// 手动将其他请求的JsonResponse写入该请求的缓存
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;

/// For subclass to overwrite
- (NSInteger)cacheTimeInSeconds;
- (long long)cacheVersion;
- (id)cacheSensitiveData;

@end
