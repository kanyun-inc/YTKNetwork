//
// Created by Chenyu Lan on 8/27/14.
// Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "YTKUrlArgumentsFilter.h"
#import "YTKUrlUtils.h"

@implementation YTKUrlArgumentsFilter {
    NSDictionary *_arguments;
}

+ (instancetype)filterWithArguments:(NSDictionary *)arguments {
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
    if (request.useCDN) {
        return originUrl;
    } else {
        return [YTKUrlUtils urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
    }
}

@end
