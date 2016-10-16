//
//  YTKBasicCacheDirFilter.h
//  YTKNetwork
//
//  Created by skyline on 16/8/14.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKNetworkConfig.h"

@interface YTKBasicCacheDirFilter : NSObject<YTKCacheDirPathFilterProtocol>

+ (instancetype)filterWithPathComponent:(NSString *)component;

@end
