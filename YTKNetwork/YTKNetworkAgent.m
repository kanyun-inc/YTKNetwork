//
//  YTKNetworkAgent.m
//
//  Copyright (c) 2012-2016 YTKNetwork https://github.com/yuantiku
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

#import "YTKNetworkAgent.h"
#import "YTKNetworkConfig.h"
#import "YTKNetworkPrivate.h"
#import <pthread/pthread.h>

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

#define kYTKNetworkIncompleteDownloadFolderName @"Incomplete"

@implementation YTKNetworkAgent {
    AFHTTPSessionManager *_manager;
    YTKNetworkConfig *_config;
    AFJSONResponseSerializer *_jsonResponseSerializer;
    AFXMLParserResponseSerializer *_xmlParserResponseSerialzier;
    NSMutableDictionary<NSString *, YTKBaseRequest *> *_requestsRecord;

    dispatch_queue_t _processingQueue;
    pthread_mutex_t _lock;
    NSIndexSet *_allStatusCodes;
}

+ (YTKNetworkAgent *)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _config = [YTKNetworkConfig sharedConfig];
        _manager = [AFHTTPSessionManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _processingQueue = dispatch_queue_create("com.yuantiku.networkagent.processing", DISPATCH_QUEUE_CONCURRENT);
        _allStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        pthread_mutex_init(&_lock, NULL);

        _manager.securityPolicy = _config.securityPolicy;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        // Take over the status code validation
        _manager.responseSerializer.acceptableStatusCodes = _allStatusCodes;
        _manager.completionQueue = _processingQueue;
    }
    return self;
}

- (AFJSONResponseSerializer *)jsonResponseSerializer {
    if (!_jsonResponseSerializer) {
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _jsonResponseSerializer.acceptableStatusCodes = _allStatusCodes;

    }
    return _jsonResponseSerializer;
}

- (AFXMLParserResponseSerializer *)xmlParserResponseSerialzier {
    if (!_xmlParserResponseSerialzier) {
        _xmlParserResponseSerialzier = [AFXMLParserResponseSerializer serializer];
        _xmlParserResponseSerialzier.acceptableStatusCodes = _allStatusCodes;
    }
    return _xmlParserResponseSerialzier;
}

#pragma mark -

- (NSString *)buildRequestUrl:(YTKBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    // Filter URL if needed
    NSArray *filters = [_config urlFilters];
    for (id<YTKUrlFilterProtocol> f in filters) {
        detailUrl = [f filterUrl:detailUrl withRequest:request];
    }

    NSString *baseUrl;
    if ([request useCDN]) {
        if ([request cdnUrl].length > 0) {
            baseUrl = [request cdnUrl];
        } else {
            baseUrl = [_config cdnUrl];
        }
    } else {
        if ([request baseUrl].length > 0) {
            baseUrl = [request baseUrl];
        } else {
            baseUrl = [_config baseUrl];
        }
    }
    // URL slash compability
    NSURL *url = [NSURL URLWithString:baseUrl];

    if (baseUrl.length > 0 && ![baseUrl hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@""];
    }

    return [NSURL URLWithString:detailUrl relativeToURL:url].absoluteString;
}

- (void)addRequest:(YTKBaseRequest *)request {
    YTKRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];

    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == YTKRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == YTKRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }

    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];

    // If api needs server username and password
    NSArray<NSString *> *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:authorizationHeaderFieldArray.firstObject
                                                          password:authorizationHeaderFieldArray.lastObject];
    }

    // If api needs to add custom value to HTTPHeaderField
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
            } else {
                YTKLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }

    // If api builds custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [_manager dataTaskWithRequest:customUrlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self handleRequestResult:dataTask responseObject:responseObject error:error];
        }];
        request.requestTask = dataTask;
    } else {
        if (method == YTKRequestMethodGET) {
            if (request.resumableDownloadPath) {
                // add parameters to URL;
                NSString *filteredUrl = [YTKNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
                NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                urlRequest.timeoutInterval = [request requestTimeoutInterval];
                urlRequest.allowsCellularAccess = [request allowsCellularAccess];

                NSString *downloadTargetPath;
                BOOL isDirectory;
                if(![[NSFileManager defaultManager] fileExistsAtPath:request.resumableDownloadPath isDirectory:&isDirectory]) {
                    isDirectory = NO;
                }
                // If targetPath is a directory, use the file name we got from the urlRequest.
                // Make sure downloadTargetPath is always a file, not directory.
                if (isDirectory) {
                    NSString *fileName = [urlRequest.URL lastPathComponent];
                    downloadTargetPath = [NSString pathWithComponents:@[request.resumableDownloadPath, fileName]];
                } else {
                    downloadTargetPath = request.resumableDownloadPath;
                }

                BOOL resumeDataFileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self incompleteDownloadTempPathForDownloadRequest:request].path];
                NSData *data = [NSData dataWithContentsOfURL:[self incompleteDownloadTempPathForDownloadRequest:request]];
                BOOL resumeDataIsValid = [YTKNetworkPrivate isResumeDataValid:data];

                BOOL canBeResumed = resumeDataFileExists && resumeDataIsValid;
                BOOL resumeSucceeded = NO;
                __block NSURLSessionDownloadTask *downloadTask = nil;
                // Try to resume with resumeData.
                // Even though we try to validate the resumeData, this may still fail and raise excecption.
                if (canBeResumed) {
                    @try {
                        downloadTask = [_manager downloadTaskWithResumeData:data progress:request.resumableDownloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                            return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
                        } completionHandler:
                                        ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                            [self handleRequestResult:downloadTask responseObject:filePath error:error];
                                        }];
                        resumeSucceeded = YES;
                    } @catch (NSException *exception) {
                        YTKLog(@"Resume download failed, reason = %@", exception.reason);
                        resumeSucceeded = NO;
                    }
                }
                if (!resumeSucceeded) {
                    downloadTask = [_manager downloadTaskWithRequest:urlRequest progress:request.resumableDownloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                        return [NSURL fileURLWithPath:downloadTargetPath isDirectory:NO];
                    } completionHandler:
                                    ^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                        [self handleRequestResult:downloadTask responseObject:filePath error:error];
                                    }];
                }
                request.requestTask = downloadTask;
            } else {
                request.requestTask = [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodPOST) {
            if (constructingBlock != nil) {
                NSError *serializationError = nil;
                NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:&serializationError];
                urlRequest.timeoutInterval = [request requestTimeoutInterval];
                urlRequest.allowsCellularAccess = [request allowsCellularAccess];

                if (serializationError) {
                    dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
                        [self handleRequestResult:nil responseObject:nil error:serializationError];
                    });
                } else {
                    __block NSURLSessionDataTask *dataTask = nil;
                    dataTask = [_manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                        [self handleRequestResult:dataTask responseObject:responseObject error:error];
                    }];
                    request.requestTask = dataTask;
                }
            } else {
                request.requestTask = [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodHEAD) {
            request.requestTask = [self dataTaskWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPUT) {
            request.requestTask = [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodDELETE) {
            request.requestTask = [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPATCH) {
            request.requestTask = [self dataTaskWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:url parameters:param];
        } else {
            YTKLog(@"Error, unsupport method type");
            return;
        }
    }

    if (!request.requestTask) {
        return;
    }
    // Set request task priority
    // !!Available on iOS 8 +
    if ([request.requestTask respondsToSelector:@selector(priority)]) {
        switch (request.requestPriority) {
            case YTKRequestPriorityHigh:
                request.requestTask.priority = NSURLSessionTaskPriorityHigh;
                break;
            case YTKRequestPriorityLow:
                request.requestTask.priority = NSURLSessionTaskPriorityLow;
                break;
            case YTKRequestPriorityDefault:
                /*!!fall through*/
            default:
                request.requestTask.priority = NSURLSessionTaskPriorityDefault;
                break;
        }
    }

    // Retain request
    YTKLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addRequestToRecord:request];
    [request.requestTask resume];
}

- (void)cancelRequest:(YTKBaseRequest *)request {
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    Lock();
    NSArray *allKeys = [_requestsRecord allKeys];
    Unlock();
    if (allKeys && allKeys.count > 0) {
        NSArray *copiedKeys = [allKeys copy];
        for (NSString *key in copiedKeys) {
            Lock();
            YTKBaseRequest *request = _requestsRecord[key];
            Unlock();
            // We are using non-recursive lock.
            // Do not lock `stop`, otherwise deadlock may occur.
            [request stop];
        }
    }
}

- (BOOL)checkResult:(YTKBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator) {
        id json = [request responseJSONObject];
        if (json) {
            result = [YTKNetworkPrivate checkJson:json withValidator:validator];
        }
    }
    return result;
}

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    NSString *key = [self requestHashKey:task];
    Lock();
    YTKBaseRequest *request = _requestsRecord[key];
    Unlock();
    if (request) {
        YTKLog(@"Finished Request: %@", NSStringFromClass([request class]));

        NSError * __autoreleasing serializationError = nil;
        BOOL succeed = NO;

        request.responseObject = responseObject;
        if ([request.responseObject isKindOfClass:[NSData class]]) {
            request.responseData = responseObject;
            request.responseString = [[NSString alloc] initWithData:responseObject encoding:[YTKNetworkPrivate stringEncodingWithRequest:request]];

            switch (request.responseSerializerType) {
                case YTKResponseSerializerTypeHTTP:
                    // Default serializer. Do nothing.
                    break;
                case YTKResponseSerializerTypeJSON:
                    request.responseObject = [self.jsonResponseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                    request.responseJSONObject = request.responseObject;
                    break;
                case YTKResponseSerializerTypeXMLParser:
                    request.responseObject = [self.xmlParserResponseSerialzier responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                    break;
            }
            succeed = (error == nil) && (serializationError == nil) && [self checkResult:request];
        } else {
            // Network error, or Download Task
            succeed = (error == nil) && [self checkResult:request];
        }
        if (succeed) {
            @autoreleasepool {
                [request requestCompletePreprocessor];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [request toggleAccessoriesWillStopCallBack];
                [request requestCompleteFilter];

                if (request.delegate != nil) {
                    [request.delegate requestFinished:request];
                }
                if (request.successCompletionBlock) {
                    request.successCompletionBlock(request);
                }
                [request toggleAccessoriesDidStopCallBack];
            });
        } else {
            request.error = serializationError ?: error;
            YTKLog(@"Request %@ failed, status code = %ld, error = %@",
                     NSStringFromClass([request class]), (long)request.responseStatusCode, error.localizedDescription);

            NSData *incompleteDownloadData = error.userInfo[NSURLSessionDownloadTaskResumeData];
            if (incompleteDownloadData) {
                [incompleteDownloadData writeToURL:[self incompleteDownloadTempPathForDownloadRequest:request] atomically:YES];
            }

            @autoreleasepool {
                [request requestFailedPreprocessor];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [request toggleAccessoriesWillStopCallBack];
                [request requestFailedFilter];

                if (request.delegate != nil) {
                    [request.delegate requestFailed:request];
                }
                if (request.failureCompletionBlock) {
                    request.failureCompletionBlock(request);
                }
                [request toggleAccessoriesDidStopCallBack];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeRequestFromRecord:request];
            [request clearCompletionBlock];
        });
    }
}

- (NSString *)requestHashKey:(NSURLSessionTask *)task {
    return [NSString stringWithFormat:@"%zd", [task hash]];
}

- (void)addRequestToRecord:(YTKBaseRequest *)request {
    if (request.requestTask != nil) {
        NSString *key = [self requestHashKey:request.requestTask];
        Lock();
        _requestsRecord[key] = request;
        Unlock();
    }
}

- (void)removeRequestFromRecord:(YTKBaseRequest *)request {
    NSString *key = [self requestHashKey:request.requestTask];
    Lock();
    if (key) {
        [_requestsRecord removeObjectForKey:key];
    }
    YTKLog(@"Request queue size = %zd", [_requestsRecord count]);
    Unlock();
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        YTKLog(@"Request serialization failed, error = %@", serializationError.localizedDescription);
        return nil;
    }

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [_manager dataTaskWithRequest:request
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                               [self handleRequestResult:dataTask responseObject:responseObject error:error];
                           }];

    return dataTask;
}

#pragma mark - Resumable Download

- (NSString *)incompleteDownloadTempCacheFolder {
    NSFileManager *fileManager = [NSFileManager new];
    static NSString *cacheFolder;

    if (!cacheFolder) {
        NSString *cacheDir = NSTemporaryDirectory();
        cacheFolder = [cacheDir stringByAppendingPathComponent:kYTKNetworkIncompleteDownloadFolderName];
    }

    NSError *error = nil;
    if(![fileManager createDirectoryAtPath:cacheFolder withIntermediateDirectories:YES attributes:nil error:&error]) {
        YTKLog(@"Failed to create cache directory at %@", cacheFolder);
        cacheFolder = nil;
    }
    return cacheFolder;
}

- (NSURL *)incompleteDownloadTempPathForDownloadRequest:(YTKBaseRequest *)request {
    NSString *tempPath = nil;
    NSString *md5URLString = [YTKNetworkPrivate md5StringFromString:request.resumableDownloadPath];
    tempPath = [[self incompleteDownloadTempCacheFolder] stringByAppendingPathComponent:md5URLString];
    return [NSURL fileURLWithPath:tempPath];
}

#pragma mark - Testing

- (AFHTTPSessionManager *)manager {
    return _manager;
}

- (void)resetURLSessionManager {
    _manager = [AFHTTPSessionManager manager];
}

- (void)resetURLSessionManagerWithConfiguration:(NSURLSessionConfiguration *)configuration {
    _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
}

@end
