//
//  YTKJSONValidatorRequest.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKJSONValidatorRequest.h"

@interface YTKJSONValidatorRequest ()

@property (nonatomic, strong) id validator;
@property (nonatomic, strong) NSString *url;

@end

@implementation YTKJSONValidatorRequest

- (instancetype)initWithJSONValidator:(id)validator requestUrl:(NSString *)requestUrl {
    self = [super init];
    if (self) {
        _validator = validator;
        _url = requestUrl;
    }
    return self;
}

- (id)jsonValidator {
    return _validator;
}

- (NSString *)requestUrl {
    return _url;
}
@end
