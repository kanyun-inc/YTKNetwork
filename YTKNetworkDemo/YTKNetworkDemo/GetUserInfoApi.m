//
//  GetUserInfoApi.m
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "GetUserInfoApi.h"

@implementation GetUserInfoApi {
    NSString *_userId;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{ @"id": _userId };
}

- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

@end
