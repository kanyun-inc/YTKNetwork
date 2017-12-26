//
//  YTKBasicCacheDirFilter.m
//  YTKNetwork
//
//  Created by skyline on 16/8/14.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKBasicCacheDirFilter.h"

@interface YTKBasicCacheDirFilter ()

@property (nonatomic, strong) NSString *pathComponent;

@end

@implementation YTKBasicCacheDirFilter

+ (instancetype)filterWithPathComponent:(NSString *)component {
    return [[self alloc] initWithComponent:component];
}

- (instancetype)initWithComponent:(NSString *)component {
    self = [super init];
    if (self) {
        _pathComponent = component;
    }
    return self;
}

- (NSString *)filterCacheDirPath:(NSString *)originPath withRequest:(YTKBaseRequest *)request {
    return  [originPath stringByAppendingPathComponent:_pathComponent];
}

@end
