//
//  FenbiDeviceNameFilter.m
//  Solar
//
//  Created by tangqiao on 8/6/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "YTKDeviceNameFilter.h"

@implementation YTKDeviceNameFilter {
    NSString *_deviceName;
}

+ (instancetype)filter {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            _deviceName = @"ipad";
        } else {
            _deviceName = @"iphone";
        }
    }
    return self;
}

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request {
    NSRange range = [originUrl rangeOfString:@"{device}"];
    if (range.location != NSNotFound) {
        return [originUrl stringByReplacingCharactersInRange:range withString:_deviceName];
    } else {
        return originUrl;
    }
}

@end
