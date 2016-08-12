//
//  YTKRequest.h
//
//  Copyright (c) 2012-2016 YTKNetwork https://github.com/yuantiku
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

NS_ASSUME_NONNULL_BEGIN

///  YTKRequest is the base class you should inherit to create your own request class.
///  Based on YTKBaseRequest, YTKRequest adds local caching feature.
@interface YTKRequest : YTKBaseRequest

///  Whether to use cache or not.
///  Default is NO, which means caching will take effect with specific arguments.
///  Note that `cacheTimeInSeconds` default is -1. As a result caching is not actually
///  enabled unless you use a positive value for `cacheTimeInSeconds`.
@property (nonatomic) BOOL ignoreCache;

///  Cached JSON object.
- (nullable id)cacheJson;

///  Whether data is from local cache.
- (BOOL)isDataFromCache;

///  Whether local cache is expired according to version.
- (BOOL)isCacheVersionExpired;

///  Start request, completely ignores caching logic.
- (void)startWithoutCache;

///  Save response object (probably from another request) to this request's cache location
- (void)saveJsonResponseToCacheFile:(id)jsonResponse;

#pragma mark - Subclass Override

///  The max time duration that cache can stay in disk until it's considered expired.
///  Default is -1, which means response is not actually saved as cache.
- (NSInteger)cacheTimeInSeconds;

///  Version can be used to identify and invalidate local cache. Default is 0.
- (long long)cacheVersion;

///  This can be used as additional identifier that tells the cache needs updating.
- (nullable id)cacheSensitiveData;

@end

NS_ASSUME_NONNULL_END
