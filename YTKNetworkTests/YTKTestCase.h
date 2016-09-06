//
//  YTKTestCase.h
//  YTKNetwork
//
//  Created by skyline on 16/8/2.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import <XCTest/XCTest.h>

@class YTKBaseRequest, YTKRequest;
@interface YTKTestCase : XCTestCase

@property (nonatomic, assign) NSTimeInterval networkTimeout;

- (void)expectSuccess:(YTKRequest *)request;
- (void)expectSuccess:(YTKRequest *)request withAssertion:(void(^)(YTKBaseRequest * request)) assertion;
- (void)expectFailure:(YTKRequest *)request;
- (void)expectFailure:(YTKRequest *)request withAssertion:(void(^)(YTKBaseRequest * request)) assertion;

- (void)waitForExpectationsWithCommonTimeout;
- (void)waitForExpectationsWithCommonTimeoutUsingHandler:(XCWaitCompletionHandler)handler;

- (void)createDirectory:(NSString *)path;
- (void)clearDirectory:(NSString *)path;

@end
