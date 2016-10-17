//
//  YTKBasicHTTPGetRequest.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/29.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetwork.h"

@interface YTKBasicHTTPRequest : YTKRequest

- (instancetype)initWithRequestUrl:(NSString *)url;
- (instancetype)initWithRequestUrl:(NSString *)url method:(YTKRequestMethod)method;

@end
