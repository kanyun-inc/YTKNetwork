//
//  FenbiDeviceNameFilter.h
//  Solar
//
//  Created by tangqiao on 8/6/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetworkConfig.h"

@interface YTKDeviceNameFilter : NSObject<YTKUrlFilterProtocol>

+ (instancetype)filter;

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request;

@end
