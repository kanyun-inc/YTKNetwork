//
//  YTKJSONValidatorRequest.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetwork.h"

@interface YTKJSONValidatorRequest : YTKRequest

- (instancetype)initWithJSONValidator:(id)validator requestUrl:(NSString *)requestUrl;

@end
