//
//  YTKBasicUrlFilter.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKBasicUrlFilter.h"
#import "YTKNetworkConfig.h"
#import "YTKNetworkPrivate.h"

@interface YTKBasicUrlFilter ()

@property NSDictionary *arguments;

@end

@implementation YTKBasicUrlFilter

+ (YTKBasicUrlFilter *)filterWithArguments:(NSDictionary *)arguments {
    return [[self alloc] initWithArguments:arguments];
}

- (instancetype)initWithArguments:(NSDictionary *)arguments {
    self = [super init];
    if (self) {
        _arguments = arguments;
    }
    return self;
}

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request {
    return [YTKNetworkPrivate urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
}

@end
