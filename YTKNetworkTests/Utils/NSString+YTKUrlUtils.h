//
//  NSString+YTKUrlUtils.h
//  YTKNetwork
//
//  Created by skyline on 16/10/7.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YTKUrlUtils)

- (NSString *)ytk_stringByAppendURLParameters:(NSDictionary *)parameters;

@end
