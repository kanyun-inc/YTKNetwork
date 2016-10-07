//
//  YTKUrlUtilsTests.m
//  YTKNetwork
//
//  Created by skyline on 16/8/10.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "YTKNetworkPrivate.h"

@interface YTKNetworkPrivateTests : XCTestCase

@end

@implementation YTKNetworkPrivateTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testFullURLWithEmptyParameters {
    NSString *originUrl = @"http://www.yuantiku.com/";
    NSDictionary *parameters = nil;
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"http://www.yuantiku.com/"]);
}

- (void)testFullURLWithSlash {
    NSString *originUrl = @"http://www.yuantiku.com/";
    NSDictionary *parameters = @{@"key": @"value"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"http://www.yuantiku.com/?key=value"]);
}

- (void)testFullURLWithNoSlash {
    NSString *originUrl = @"http://www.yuantiku.com";
    NSDictionary *parameters = @{@"key": @"value"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"http://www.yuantiku.com?key=value"]);
}

- (void)testFullURLWithParameters {
    NSString *originUrl = @"http://www.yuantiku.com?key1=value1";
    NSDictionary *parameters = @{@"key2": @"value2"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"http://www.yuantiku.com?key1=value1&key2=value2"]);
}

- (void)testFullURLWithFragment {
    NSString *originUrl = @"http://www.yuantiku.com?key1=value1#frag1";
    NSDictionary *parameters = @{@"key2": @"value2"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"http://www.yuantiku.com?key1=value1&key2=value2#frag1"]);
}

- (void)testDetailURLWithEmptyParameters {
    NSString *originUrl = @"get/";
    NSDictionary *parameters = nil;
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"get/"]);
}

- (void)testDetailURLWithSlash {
    NSString *originUrl = @"get/";
    NSDictionary *parameters = @{@"key": @"value"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"get/?key=value"]);
}

- (void)testDetailURLWithNoSlash {
    NSString *originUrl = @"get";
    NSDictionary *parameters = @{@"key": @"value"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"get?key=value"]);
}

- (void)testDetailURLWithParameters {
    NSString *originUrl = @"get?key1=value1";
    NSDictionary *parameters = @{@"key2": @"value2"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"get?key1=value1&key2=value2"]);
}

- (void)testDetailURLWithFragment {
    NSString *originUrl = @"get?key1=value1#frag1";
    NSDictionary *parameters = @{@"key2": @"value2"};
    NSString *resultUrl = [YTKNetworkUtils urlStringWithOriginUrlString:originUrl appendParameters:parameters];

    XCTAssertTrue([resultUrl isEqualToString:@"get?key1=value1&key2=value2#frag1"]);
}

@end
