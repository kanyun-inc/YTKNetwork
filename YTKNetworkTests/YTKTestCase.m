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
    [YTKNetworkConfig sharedInstance].baseUrl = YTKNetworkingTestsBaseURLString;
}

- (void)tearDown {
    [super tearDown];
    [[YTKNetworkAgent sharedInstance] cancelAllRequests];
    [YTKNetworkConfig sharedInstance].baseUrl = @"";
    [YTKNetworkConfig sharedInstance].cdnUrl = @"";
    [[YTKNetworkConfig sharedInstance] clearUrlFilter];
    [[YTKNetworkConfig sharedInstance] clearCacheDirPathFilter];
}

- (void)expectSuccess:(YTKRequest *)request {
    [self expectSuccess:request withAssertion:nil];
}

- (void)expectSuccess:(YTKRequest *)request withAssertion:(void(^)(YTKBaseRequest * request)) assertion {
    XCTestExpectation *exp = [self expectationWithDescription:@"Request should succeed"];

    [request startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTAssertNotNil(request);
        if (assertion) {
            assertion(request);
        }
        [exp fulfill];
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTFail(@"Request should succeed, but failed");
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
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        XCTAssertNotNil(request);
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

@end
