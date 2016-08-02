//
//  YTKTImeoutRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKTimeoutRequest.h"

@interface YTKTimeoutRequest ()

@property (nonatomic, assign) NSTimeInterval timeout;
@property (nonatomic, strong) NSString *url;

@end

@implementation YTKTimeoutRequest

- (instancetype)initWithTimeout:(NSTimeInterval)timeout requestUrl:(NSString *)requestUrl {
    self = [super init];
    if (self) {
        _timeout = timeout;
        _url = requestUrl;
    }
    return self;
}

- (NSTimeInterval)requestTimeoutInterval {
    return _timeout;
}

- (NSString *)requestUrl {
    return _url;
}

@end
