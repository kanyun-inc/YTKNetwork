//
//  YTKTestCase.m
//  YTKNetwork
//
//  Created by skyline on 16/8/2.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKNetworkConfig.h"
#import "YTKNetworkAgent.h"
#import "YTKRequest.h"

NSString * const YTKNetworkingTestsBaseURLString = @"https://httpbin.org/";

@implementation YTKTestCase

- (void)setUp {
    [super setUp];
    self.networkTimeout = 20.0;
    [YTKNetworkConfig sharedConfig].baseUrl = YTKNetworkingTestsBaseURLString;
}

- (void)tearDown {
    [super tearDown];
    [[YTKNetworkAgent sharedAgent] cancelAllRequests];
    [YTKNetworkConfig sharedConfig].baseUrl = @"";
    [YTKNetworkConfig sharedConfig].cdnUrl = @"";
    [[YTKNetworkConfig sharedConfig] clearUrlFilter];
    [[YTKNetworkConfig sharedConfig] clearCacheDirPathFilter];
}

- (void)expectSuccess:(YTKRequest *)request {
    [self expectSuccess:request withAssertion:nil];
}

- (void)expectSuccess:(YTKRequest *)request withAssertion:(void(^)(YTKBaseRequest * request)) assertion {
    XCTestExpectation *exp = [self expectationWithDescription:@"Request should succeed"];

    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTAssertNotNil(request);
        XCTAssertNil(request.error);
        if (assertion) {
            assertion(request);
        }
        [exp fulfill];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTFail(@"Request should succeed, but failed");
        [exp fulfill];
    }];

    [self waitForExpectationsWithCommonTimeout];
}

- (void)expectFailure:(YTKRequest *)request {
    [self expectFailure:request withAssertion:nil];
}

- (void)expectFailure:(YTKRequest *)request withAssertion:(void(^)(YTKBaseRequest * request)) assertion {
    XCTestExpectation *exp = [self expectationWithDescription:@"Request should fail"];

    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTFail(@"Request should fail, but succeeded");
        [exp fulfill];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTAssertNotNil(request);
        XCTAssertNotNil(request.error);
        if (assertion) {
            assertion(request);
        }
        [exp fulfill];
    }];

    [self waitForExpectationsWithCommonTimeout];
}

- (void)waitForExpectationsWithCommonTimeout {
    [self waitForExpectationsWithCommonTimeoutUsingHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler {
    [self waitForExpectationsWithTimeout:self.networkTimeout handler:handler];
}

#pragma mark -

- (void)createDirectory:(NSString *)path {
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES
                                               attributes:nil error:&error];
    if (error) {
        NSLog(@"Create directory error: %@", error);
    }
}

- (void)clearDirectory:(NSString *)path {
    NSFileManager* fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:path isDirectory:nil]) {
        return;
    }
    NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:path];
    NSError *err = nil;
    BOOL res;

    NSString* file;
    while (file = [enumerator nextObject]) {
        res = [fileManager removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"Delete file error: %@", err);
        }
    }
}

@end
