//
//  YTKBasicUrlFilter.h
//  YTKNetworkDemo
//
//  Created by skyline on 16/7/30.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetworkConfig.h"

@protocol YTKUrlFilterProtocol;
@interface YTKBasicUrlFilter : NSObject<YTKUrlFilterProtocol>

+ (instancetype)filterWithArguments:(NSDictionary<NSString *, NSString *> *)arguments;

@end
