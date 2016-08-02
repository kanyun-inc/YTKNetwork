//
//  YTKCustomHeaderFieldRequest.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetwork.h"

@interface YTKCustomHeaderFieldRequest : YTKRequest

- (instancetype)initWithCustomHeaderField:(NSDictionary<NSString *, NSString *> *)headers requestUrl:(NSString *)requestUrl;

@end
