//
//  YTKCustomCacheRequest.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/8/12.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKBasicHTTPRequest.h"

@interface YTKCustomCacheRequest : YTKBasicHTTPRequest

- (instancetype)initWithRequestUrl:(NSString *)url cacheTimeInSeconds:(NSInteger)time;

- (instancetype)initWithRequestUrl:(NSString *)url cacheTimeInSeconds:(NSInteger)time cacheVersion:(long long)version cacheSensitiveData:(id)sensitiveData;

@end
