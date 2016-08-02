//
//  YTKBasicAuthRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKBasicAuthRequest.h"

@interface YTKBasicAuthRequest ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *url;

@end

@implementation YTKBasicAuthRequest

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password requestUrl:(NSString *)requestUrl {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
        _url = requestUrl;
    }
    return self;
}

- (NSString *)requestUrl {
    return _url;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return @[_username, _password];
}

@end
