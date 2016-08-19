//
//  YTKNetworkDemoTests.m
//  YTKNetworkDemoTests
//
//  Created by Chenyu Lan on 10/28/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKNetworkConfig.h"
#import "YTKBasicHTTPRequest.h"
#import "YTKXMLRequest.h"
#import "YTKBasicAuthRequest.h"
#import "YTKCustomHeaderFieldRequest.h"
#import "YTKJSONValidatorRequest.h"
#import "YTKStatusCodeValidatorRequest.h"
#import "YTKTImeoutRequest.h"

@interface YTKNetworkRequestTests : YTKTestCase

@end

@implementation YTKNetworkRequestTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicHTTPRequest {
    YTKBasicHTTPRequest *get = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get" method:YTKRequestMethodGET];
    [self expectSuccess:get];

    YTKBasicHTTPRequest *post = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"post" method:YTKRequestMethodPOST];
    [self expectSuccess:post];

    YTKBasicHTTPRequest *patch = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"patch" method:YTKRequestMethodPATCH];
    [self expectSuccess:patch];

    YTKBasicHTTPRequest *put = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"put" method:YTKRequestMethodPUT];
    [self expectSuccess:put];

    YTKBasicHTTPRequest *delete = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"delete" method:YTKRequestMethodDELETE];
    [self expectSuccess:delete];

    YTKBasicHTTPRequest *fail404 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"status/404" method:YTKRequestMethodGET];
    [self expectFailure:fail404];
}

- (void)testResponseHeaders {
    YTKBasicHTTPRequest *req = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"response-headers?key=value"];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        NSDictionary<NSString *, NSString *> *responseHeaders = request.responseHeaders;
        XCTAssertNotNil(responseHeaders);
        XCTAssertTrue([responseHeaders[@"key"] isEqualToString:@"value"]);
    }];
}

- (void)testCustomHeaderField {
    YTKCustomHeaderFieldRequest *req = [[YTKCustomHeaderFieldRequest alloc] initWithCustomHeaderField:@{@"Custom-Header-Field": @"CustomHeaderValue"} requestUrl:@"headers"];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        XCTAssertNotNil(request.responseJSONObject);
        NSDictionary<NSString *, NSString *> *headers = request.responseJSONObject[@"headers"];
        XCTAssertTrue([headers[@"Custom-Header-Field"] isEqualToString:@"CustomHeaderValue"]);
    }];
}

- (void)testHTTPBasicAuthRequest {
    YTKBasicAuthRequest *authSuccess = [[YTKBasicAuthRequest alloc] initWithUsername:@"123" password:@"123" requestUrl:@"basic-auth/123/123"];
    [self expectSuccess:authSuccess];

    YTKBasicAuthRequest *authFailure = [[YTKBasicAuthRequest alloc] initWithUsername:@"123456" password:@"123" requestUrl:@"basic-auth/123/123"];
    [self expectFailure:authFailure];
}

- (void)testJSONValidator {
    YTKJSONValidatorRequest *validateSuccess = [[YTKJSONValidatorRequest alloc] initWithJSONValidator:@{@"headers": [NSDictionary class], @"args": [NSDictionary class]} requestUrl:@"get?key1=value&key2=123456"];
    [self expectSuccess:validateSuccess];

    YTKJSONValidatorRequest *validateFailure = [[YTKJSONValidatorRequest alloc] initWithJSONValidator:@{@"headers": [NSDictionary class], @"args": [NSString class]} requestUrl:@"get?key1=value&key2=123456"];
    [self expectFailure:validateFailure];
}

- (void)testXMLRequest {
    YTKXMLRequest *req = [[YTKXMLRequest alloc] initWithRequestUrl:@"xml"];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        XCTAssertNotNil(request);
        XCTAssertTrue([request.responseObject isMemberOfClass:[NSXMLParser class]]);
    }];
}

- (void)testStatusCodeValidator {
    YTKStatusCodeValidatorRequest *validateSuccess = [[YTKStatusCodeValidatorRequest alloc] initWithRequestUrl:@"status/418"];
    [self expectSuccess:validateSuccess];

    YTKStatusCodeValidatorRequest *validateFailure = [[YTKStatusCodeValidatorRequest alloc] initWithRequestUrl:@"status/200"];
    [self expectFailure:validateFailure];
}

- (void)testBatchRequest {
    YTKBasicHTTPRequest *req1 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key1=value1"];
    YTKBasicHTTPRequest *req2 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key2=value2"];
    YTKBasicHTTPRequest *req3 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key3=value3"];

    XCTestExpectation *exp = [self expectationWithDescription:@"Batch Request should succeed"];

    YTKBatchRequest *batch = [[YTKBatchRequest alloc] initWithRequestArray:@[req1, req2, req3]];
    [batch startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        XCTAssertNotNil(batchRequest);
        XCTAssertEqual(batchRequest.requestArray.count, 3);

        YTKRequest *req1 = batchRequest.requestArray[0];
        NSDictionary<NSString *, NSString *> *responseArgs1 = req1.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs1[@"key1"] isEqualToString:@"value1"]);

        YTKRequest *req2 = batchRequest.requestArray[1];
        NSDictionary<NSString *, NSString *> *responseArgs2 = req2.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs2[@"key2"] isEqualToString:@"value2"]);

        YTKRequest *req3 = batchRequest.requestArray[2];
        NSDictionary<NSString *, NSString *> *responseArgs3 = req3.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs3[@"key3"] isEqualToString:@"value3"]);

        [exp fulfill];
    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        XCTFail(@"Batch Request should succeed, but failed");
    }];

    [self waitForExpectationsWithCommonTimeout];
}

- (void)testChainRequest {
    YTKBasicHTTPRequest *req1 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key1=value1"];
    YTKBasicHTTPRequest *req2 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key2=value2"];
    YTKBasicHTTPRequest *req3 = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get?key3=value3"];

    XCTestExpectation *exp = [self expectationWithDescription:@"Chain Request should succeed"];

    YTKChainRequest *chain = [[YTKChainRequest alloc] init];
    [chain addRequest:req1 callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
        NSDictionary<NSString *, NSString *> *responseArgs1 = baseRequest.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs1[@"key1"] isEqualToString:@"value1"]);

        [chainRequest addRequest:req2 callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
            NSDictionary<NSString *, NSString *> *responseArgs2 = baseRequest.responseJSONObject[@"args"];
            XCTAssertTrue([responseArgs2[@"key2"] isEqualToString:@"value2"]);

            [chainRequest addRequest:req3 callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
                NSDictionary<NSString *, NSString *> *responseArgs3 = baseRequest.responseJSONObject[@"args"];
                XCTAssertTrue([responseArgs3[@"key3"] isEqualToString:@"value3"]);

                [exp fulfill];
            }];
        }];
    }];
    [chain start];

    [self waitForExpectationsWithCommonTimeout];
}

- (void)testTimeoutRequest {
    YTKTimeoutRequest *timeoutSuccess = [[YTKTimeoutRequest alloc] initWithTimeout:5 requestUrl:@"delay/3"];
    [self expectSuccess:timeoutSuccess];

    YTKTimeoutRequest *timeoutFailure = [[YTKTimeoutRequest alloc] initWithTimeout:5 requestUrl:@"delay/7"];
    [self expectFailure:timeoutFailure];
}

@end
