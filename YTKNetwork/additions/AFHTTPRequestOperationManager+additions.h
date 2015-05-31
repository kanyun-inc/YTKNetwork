//
//  AFHTTPRequestOperationManager+additions.h
//  EverPhoto
//
//  Created by null on 15/5/29.
//  Copyright (c) 2015年 bytedance. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (additions)

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
