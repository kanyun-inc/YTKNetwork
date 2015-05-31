//
//  AFHTTPRequestOperationManager+additions.m
//  EverPhoto
//
//  Created by null on 15/5/29.
//  Copyright (c) 2015年 bytedance. All rights reserved.
//

#import "AFHTTPRequestOperationManager+additions.h"

@implementation AFHTTPRequestOperationManager (additions)

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{

    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:URLString parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    [request setValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"chunked" forHTTPHeaderField:@"Transfer-Encoding"];
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
    
}

@end
