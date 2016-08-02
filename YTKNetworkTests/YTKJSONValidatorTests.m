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

- (void)testCompoundDictionaryVailidateShouldSucceed {
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
    BOOL result = [self checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}

- (void)testCompoundDictionaryVailidateShouldFail {
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
    BOOL result = [self checkJson:json withValidator:validator];
    XCTAssertFalse(result);
}

- (void)testSimpleArrayValidatorShouldSucceed {
    NSArray *json = @[@1 , @2];
    NSArray *validator = @[[NSNumber class]];
    BOOL result = [self checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}

- (void)testSimpleArrayValidatorShouldFail {
    NSArray *json = @[@1 , @2];
    NSArray *validator = @[[NSString class]];
    BOOL result = [self checkJson:json withValidator:validator];
    XCTAssertFalse(result);
}

- (void)testEmptyArrayValidatorShouldSucceed {
    NSArray *json = @[@{
        @"values": @[]
    }];
    NSArray *validator = @[@{
        @"values": @[]
    }];
    BOOL result = [self checkJson:json withValidator:validator];
    XCTAssertTrue(result);
}

- (BOOL)checkJson:(id)json withValidator:(id)validatorJson {
    return [YTKNetworkPrivate checkJson:json withValidator:validatorJson];
}

@end
