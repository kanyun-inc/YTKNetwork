//
//  YTKNetworkAgent.m
//
//  Copyright (c) 2012-2014 YTKNetwork https://github.com/yuantiku
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
#import "AFDownloadRequestOperation.h"
#import "AFNetworking.h"

@implementation YTKNetworkAgent {
    AFHTTPRequestOperationManager *_manager;
    YTKNetworkConfig *_config;
    NSMutableDictionary<NSString *, YTKBaseRequest *> *_requestsRecord;
    dispatch_queue_t _requestProcessingQueue;
}

+ (YTKNetworkAgent *)sharedInstance {
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
        _config = [YTKNetworkConfig sharedInstance];
        _manager = [AFHTTPRequestOperationManager manager];
        _requestsRecord = [NSMutableDictionary dictionary];
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.securityPolicy = _config.securityPolicy;
    }
    return self;
}

- (NSString *)buildRequestUrl:(YTKBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    // filter url
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
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
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

    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                          password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }

    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                YTKLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }

    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:customUrlRequest];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self handleRequestResult:operation];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self handleRequestResult:operation];
        }];
        request.requestOperation = operation;
        operation.responseSerializer = _manager.responseSerializer;
        [_manager.operationQueue addOperation:operation];
    } else {
        if (method == YTKRequestMethodGet) {
            if (request.resumableDownloadPath) {
                // add parameters to URL;
                NSString *filteredUrl = [YTKNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];

                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
                                                                                                 targetPath:request.resumableDownloadPath shouldResume:YES];
                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [self handleRequestResult:operation];
                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    [self handleRequestResult:operation];
                }];
                request.requestOperation = operation;
                [_manager.operationQueue addOperation:operation];
            } else {
                request.requestOperation = [self requestOperationWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodPost) {
            if (constructingBlock != nil) {
                NSError *serializationError = nil;
                NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:&serializationError];
                if (serializationError) {
                    dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
                        [self handleRequestResult:nil];
                    });
                } else {
                    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [self handleRequestResult:operation];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        [self handleRequestResult:operation];
                    }];
                    request.requestOperation = operation;
                    [_manager.operationQueue addOperation:operation];
                }
            } else {
                request.requestOperation = [self requestOperationWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param];
            }
        } else if (method == YTKRequestMethodHead) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPut) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodDelete) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param];
        } else if (method == YTKRequestMethodPatch) {
            request.requestOperation = [self requestOperationWithHTTPMethod:@"PATCH" requestSerializer:requestSerializer URLString:url parameters:param];
        } else {
            YTKLog(@"Error, unsupport method type");
            return;
        }
    }

    // Set request operation priority
    switch (request.requestPriority) {
        case YTKRequestPriorityHigh:
            request.requestOperation.queuePriority = NSOperationQueuePriorityHigh;
            break;
        case YTKRequestPriorityLow:
            request.requestOperation.queuePriority = NSOperationQueuePriorityLow;
            break;
        case YTKRequestPriorityDefault:
        default:
            request.requestOperation.queuePriority = NSOperationQueuePriorityNormal;
            break;
    }

    // retain operation
    YTKLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addOperation:request];
}

- (void)cancelRequest:(YTKBaseRequest *)request {
    [request.requestOperation cancel];
    [self removeOperation:request.requestOperation];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecord copy];
    for (NSString *key in copyRecord) {
        YTKBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

- (BOOL)checkResult:(YTKBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

- (void)handleRequestResult:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    YTKBaseRequest *request = _requestsRecord[key];
    YTKLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request toggleAccessoriesWillStopCallBack];
            [request requestCompleteFilter];
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        } else {
            YTKLog(@"Request %@ failed, status code = %ld",
                     NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
    [self removeOperation:operation];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(AFHTTPRequestOperation *)operation {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[operation hash]];
    return key;
}

- (void)addOperation:(YTKBaseRequest *)request {
    if (request.requestOperation != nil) {
        NSString *key = [self requestHashKey:request.requestOperation];
        @synchronized(self) {
            _requestsRecord[key] = request;
        }
    }
}

- (void)removeOperation:(AFHTTPRequestOperation *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecord removeObjectForKey:key];
    }
    YTKLog(@"Request queue size = %lu", (unsigned long)[_requestsRecord count]);
}

- (AFHTTPRequestOperation *)requestOperationWithHTTPMethod:(NSString *)method
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil];
        });
        return nil;
    }

    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleRequestResult:operation];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleRequestResult:operation];
    }];

    [_manager.operationQueue addOperation:operation];

    return operation;
}

- (AFHTTPRequestOperation *)requestOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = _manager.responseSerializer;
    operation.shouldUseCredentialStorage = _manager.shouldUseCredentialStorage;
    operation.credential = _manager.credential;
    operation.securityPolicy = _manager.securityPolicy;

    [operation setCompletionBlockWithSuccess:success failure:failure];
    operation.completionQueue = _manager.completionQueue;
    operation.completionGroup = _manager.completionGroup;

    return operation;
}

@end
