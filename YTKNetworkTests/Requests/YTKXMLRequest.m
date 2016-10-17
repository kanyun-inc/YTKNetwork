//
//  YTKXMLRequest.m
//  YTKNetwork
//
//  Created by skyline on 16/8/10.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKXMLRequest.h"

@implementation YTKXMLRequest

- (YTKResponseSerializerType)responseSerializerType {
    return YTKResponseSerializerTypeXMLParser;
}

@end
