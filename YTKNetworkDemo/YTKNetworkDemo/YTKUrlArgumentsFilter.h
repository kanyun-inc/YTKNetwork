//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetworkConfig.h"
#import "YTKBaseRequest.h"

/// 给url追加arguments，用于全局参数，比如AppVersion, ApiVersion等
@interface YTKUrlArgumentsFilter : NSObject <YTKUrlFilterProtocol>

+ (YTKUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments;

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request;

@end
