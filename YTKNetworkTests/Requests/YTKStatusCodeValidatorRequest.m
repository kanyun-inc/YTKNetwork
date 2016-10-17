//
//  YTKStatusCodeValidatorRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKStatusCodeValidatorRequest.h"

@interface YTKStatusCodeValidatorRequest ()

@property (nonatomic, strong) NSString *url;

@end

@implementation YTKStatusCodeValidatorRequest

- (instancetype)initWithRequestUrl:(NSString *)requestUrl {
    self = [super init];
    if (self) {
        _url = requestUrl;
    }
    return self;
}

- (NSString *)requestUrl {
    return _url;
}

- (BOOL)statusCodeValidator {
    return [self responseStatusCode] == 418;// 418 I'm a teapot
}

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeHTTP;
}

@end
