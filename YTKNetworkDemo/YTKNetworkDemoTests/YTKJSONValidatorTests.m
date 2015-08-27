//
//  YTKJSONValidatorTests.m
//  YTKNetworkDemo
//
//  Created by tangqiao on 6/10/15.
//  Copyright (c) 2015 yuantiku.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "YTKNetworkPrivate.h"

@interface YTKJSONValidatorTests : XCTestCase

@end

@implementation YTKJSONValidatorTests

- (void)testDictionaryVailidate1 {
    NSDictionary *json = @{
        @"son": @{
            @"age": @14,
        },
        @"name": @"family"
    };
    NSDictionary *validator = @{
        @"son": [NSDictionary class],
        @"name": [NSString class]
    };
    BOOL result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}

- (void)testDictionaryVailidate2 {
    NSDictionary *json = @{
        @"son": @{
            @"age": @14,
        },
        @"name": @"family"
    };
    NSDictionary *validator = @{
        @"son": [NSDictionary class],
        @"name": [NSNumber class]
    };
    BOOL result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    XCTAssertFalse(result);
}

- (void)testArayValidator1 {
    NSArray *json = @[ @1 , @2 ];
    NSArray *validator = @[[NSNumber class] ];
    BOOL result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}

- (void)testArayValidator2 {
    NSArray *json = @[ @1 , @2 ];
    NSArray *validator = @[[NSString class] ];
    BOOL result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    XCTAssertFalse(result);
}

- (void)testArayValidator3 {
    NSArray *json = @[ @{
        @"values": @[]
    } ];
    NSArray *validator = @[ @{ @"values": @[] } ];
    BOOL result = [YTKNetworkPrivate checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}



@end
