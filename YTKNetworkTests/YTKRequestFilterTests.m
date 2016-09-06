//
//  YTKRequestFilterTests.m
//  YTKNetwork
//
//  Created by skyline on 16/8/2.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKNetwork.h"
#import "YTKBasicUrlFilter.h"
#import "YTKBasicHTTPRequest.h"

@interface YTKRequestFilterTests : YTKTestCase

@end

@implementation YTKRequestFilterTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicFilter {
    YTKBasicUrlFilter *filter = [YTKBasicUrlFilter filterWithArguments:@{@"key": @"value"}];
    [[YTKNetworkConfig sharedConfig] addUrlFilter:filter];

    YTKBasicHTTPRequest *req = [[YTKBasicHTTPRequest alloc] initWithRequestUrl:@"get"];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        NSDictionary<NSString *, NSString *> *args = request.responseJSONObject[@"args"];
        XCTAssertTrue([args[@"key"] isEqualToString:@"value"]);
    }];
}

@end
