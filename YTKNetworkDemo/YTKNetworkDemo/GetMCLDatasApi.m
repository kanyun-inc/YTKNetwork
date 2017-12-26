//
//  GetMCLDatasApi.m
//  YTKNetworkDemo
//
//  Created by ligui on 2017/12/26.
//  Copyright © 2017年 yuantiku.com. All rights reserved.
//

#import "GetMCLDatasApi.h"//6568

@implementation GetMCLDatasApi
- (NSString *)requestUrl {
    return @"api/MCL/ToDayMCL";
}

- (id)requestArgument {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    return @{ @"userid": @"6568"};
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3;
}

@end
