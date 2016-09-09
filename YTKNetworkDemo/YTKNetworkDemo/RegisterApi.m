//
//  RegisterApi.m
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "RegisterApi.h"

@implementation RegisterApi {
    NSString *_username;
    NSString *_password;
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/register";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    return @{
        @"username": _username,
        @"password": _password
    };
}

- (id)jsonValidator {
    return @{
        @"userId": [NSNumber class],
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}

- (NSString *)userId {
    return [[[self responseJSONObject] objectForKey:@"userId"] stringValue];
}

@end
