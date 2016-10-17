//
//  YTKBasicAuthRequest.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetwork.h"

@interface YTKBasicAuthRequest : YTKRequest

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password requestUrl:(NSString *)requestUrl;

@end
