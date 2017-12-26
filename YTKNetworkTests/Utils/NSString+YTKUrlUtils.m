//
//  NSString+YTKUrlUtils.m
//  YTKNetwork
//
//  Created by skyline on 16/10/7.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "NSString+YTKUrlUtils.h"
#import <AFNetworking/AFNetworking.h>

@implementation NSString (YTKUrlUtils)

- (NSString *)ytk_stringByAppendURLParameters:(NSDictionary *)parameters {
    NSString *paraUrlString = AFQueryStringFromParameters(parameters);

    if (!(paraUrlString.length > 0)) {
        return self;
    }

    BOOL useDummyUrl = NO;
    static NSString *dummyUrl = nil;
    NSURLComponents *components = [NSURLComponents componentsWithString:self];
    if (!components) {
        useDummyUrl = YES;
        if (!dummyUrl) {
            dummyUrl = @"http://www.dummy.com";
        }
        components = [NSURLComponents componentsWithString:dummyUrl];
    }

    NSString *queryString = components.query ?: @"";
    NSString *newQueryString = [queryString stringByAppendingFormat:queryString.length > 0 ? @"&%@" : @"%@", paraUrlString];

    components.query = newQueryString;

    if (useDummyUrl) {
        return [components.URL.absoluteString substringFromIndex:dummyUrl.length - 1];
    } else {
        return components.URL.absoluteString;
    }
}

@end
