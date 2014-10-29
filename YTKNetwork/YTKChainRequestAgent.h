//
//  ChainRequestAgent.h
//  Ape_uni
//
//  Created by TangQiao on 13-11-1.
//  Copyright (c) 2013年 Fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTKChainRequest.h"

// ChainRequestAgent is used for caching & keeping current request.
@interface YTKChainRequestAgent : NSObject

+ (YTKChainRequestAgent *)sharedInstance;

- (void)addChainRequest:(YTKChainRequest *)request;

- (void)removeChainRequest:(YTKChainRequest *)request;

@end
