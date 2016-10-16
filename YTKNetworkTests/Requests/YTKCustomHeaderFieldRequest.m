//
//  YTKCustomHeaderFieldRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKCustomHeaderFieldRequest.h"

@interface YTKCustomHeaderFieldRequest ()

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *headers;
@property (nonatomic, strong) NSString *url;

@end

@implementation YTKCustomHeaderFieldRequest

- (instancetype)initWithCustomHeaderField:(NSDictionary<NSString *, NSString *> *)headers requestUrl:(NSString *)requestUrl {
    self = [super init];
    if (self) {
        _headers = headers;
        _url = requestUrl;
    }
    return self;
}

- (NSString *)requestUrl {
    return _url;
}

- (NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary {
    return _headers;
}
@end
