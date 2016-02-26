//
//  AFHTTPRequestOperationManager+Progress.h
//
//  Created by WangShunzhou on 14-8-22.
//  Copyright (c) 2014年 HXQC. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AFHTTPRequestOperationManager.h"

@interface AFHTTPRequestOperationManager (Progress)

/**
 *  Upload file with progress
 *
 *  @param URLString
 *  @param parameters
 *  @param uploadProgress
 *  @param block          AFMultipartFormData    Construct form data.
 *  @param success
 *  @param failure
 *
 *  @return AFHttpRequestOperation
 */
- (AFHTTPRequestOperation *)POST:(NSString *)URLString
                      parameters:(id)parameters
                        progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
       constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


/**
 *  Download file with progress
 *
 *  @param URLString
 *  @param parameters
 *  @param filePath
 *  @param downloadProgress
 *  @param success
 *  @param failure          
 *
 *  @return AFHTTPRequestOperation
 */
- (AFHTTPRequestOperation *)GET:(NSString *)URLString
                     parameters:(id)parameters
                       filePath:(NSString*)filePath
               downloadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))downloadProgress
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
