//
//  ChainRequestAgent.m
//  Ape_uni
//
//  Created by TangQiao on 13-11-1.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import "YTKChainRequestAgent.h"

@interface YTKChainRequestAgent()

@property (strong, nonatomic) NSMutableArray *requestArray;

@end

@implementation YTKChainRequestAgent

+ (YTKChainRequestAgent *)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _requestArray = [NSMutableArray array];
    }
    return self;
}

- (void)addChainRequest:(YTKChainRequest *)request {
    [_requestArray addObject:request];
}

- (void)removeChainRequest:(YTKChainRequest *)request {
    [_requestArray removeObject:request];
}

@end
