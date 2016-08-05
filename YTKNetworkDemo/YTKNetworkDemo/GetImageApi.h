//
//  GetImageApi.h
//  YTKNetworkDemo
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "YTKRequest.h"

@interface GetImageApi : YTKRequest
@property (nonatomic, strong) NSString *imageId;
- (id)initWithImageId:(NSString *)imageId;

@end
