//
//  YTKBasicHTTPGetRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/29.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKBasicHTTPRequest.h"

@interface YTKBasicHTTPRequest ()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) YTKRequestMethod method;

@end

@implementation YTKBasicHTTPRequest

- (instancetype)initWithRequestUrl:(NSString *)url {
    return [self initWithRequestUrl:url method:YTKRequestMethodGET];
}

- (instancetype)initWithRequestUrl:(NSString *)url method:(YTKRequestMethod)method {
    self = [super init];
    if (self) {
        _url = url;
        _method = method;
    }
    return self;
}
- (NSString *)requestUrl {
    return _url;
}

- (YTKRequestMethod)requestMethod {
    return _method;
}

@end
