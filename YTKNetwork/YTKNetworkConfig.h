//
//  YTKNetworkConfig.h
//  Solar
//
//  Created by tangqiao on 8/4/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKBaseRequest.h"

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
@property (strong, nonatomic, readonly) NSArray *urlFilters;
@property (strong, nonatomic, readonly) NSArray *cacheDirPathFilters;

- (void)addUrlFilter:(id<YTKUrlFilterProtocol>)filter;
- (void)addCacheDirPathFilter:(id <YTKCacheDirPathFilterProtocol>)filter;

@end
