//
//  YTKCacheTests.m
//  YTKNetworkDemo
//
//  Created by skyline on 16/8/12.
//  Copyright © 2016年 yuantiku.com. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKCustomCacheRequest.h"
#import "YTKNetworkPrivate.h"
#import "YTKBasicCacheDirFilter.h"

@interface YTKCacheTests : YTKTestCase

@end

@implementation YTKCacheTests

- (void)setUp {
    [super setUp];
    [self clearCache];
}

- (void)tearDown {
    [super tearDown];
    [self clearCache];
}

- (void)clearCache {
    YTKRequest *dummpRequest = [[YTKRequest alloc] init];
    NSString *cacheBasePath = [dummpRequest cacheBasePath];
    [self clearDirectory:cacheBasePath];
}

- (void)testBasicCache {
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again.
    // !! Do not put breakpoint here. Otherwise the "now" time will be invalid because debugger pause the program and the tests would fail.
    // Same for tests below.
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];

    sleep(5);

    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        // Cache should be expired.
        YTKRequest *_req = (YTKRequest *)request;
        XCTAssertFalse(_req.isDataFromCache);
    }];
}

- (void)testIgnoreCache {
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];

    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];

    req2.ignoreCache = YES;
    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // Cache should be ignored.
        XCTAssertFalse(_req.isDataFromCache);
    }];
}

- (void)testStartWithoutCache {
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];

    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    XCTestExpectation *exp = [self expectationWithDescription:@"Cache should be ignored"];

    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    req2.successCompletionBlock = ^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // Cache should be ignored.
        XCTAssertFalse(_req.isDataFromCache);
        [exp fulfill];
    };
    [req2 startWithoutCache];

    [self waitForExpectationsWithCommonTimeout];

    // Starting without cache does not affect the storage of cache data.
    YTKCustomCacheRequest *req3 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    [self expectSuccess:req3 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];
}

- (void)testCacheVersion {
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again.
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];

    // Request with same URL but newer version.
    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:1 cacheSensitiveData:nil];

    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // Data should not be from cache because version has changed.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again with newer version.
    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];
}

- (void)testCacheSensitiveData {
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:@{@"userId": @"123456"}];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again.
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];

    // Request with same URL but diffenert sensitive data.
    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:@{@"userId": @"456789"}];

    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // Data should not be from cache because sensitive data has changed.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request with same URL but no sensitive data.
    YTKCustomCacheRequest *req3 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];

    [self expectSuccess:req3 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // Data should not be from cache because sensitive data has changed.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again with newer sensitive data. This time previous cache is considered invalid.
    YTKCustomCacheRequest *req4 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:@{@"userId": @"456789"}];

    [self expectSuccess:req4 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again with newer sensitive data. This time cache is valid again.
    YTKCustomCacheRequest *req5 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:@{@"userId": @"456789"}];

    [self expectSuccess:req5 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];
}

- (void)testCacheIntegrityWithJSONResponse {
    __block NSDictionary *originalJSONResponse;
    __block NSString *originalStringResponse;
    __block NSData *originalData;
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        originalJSONResponse = _req.responseJSONObject;
        originalStringResponse = _req.responseString;
        originalData = _req.responseData;
        XCTAssertFalse(_req.isDataFromCache);
    }];

    // Request again.
    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];

    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
        // Check if data is the same.
        XCTAssertTrue([_req.responseJSONObject isEqualToDictionary:originalJSONResponse]);
        XCTAssertTrue([_req.responseString isEqualToString:originalStringResponse]);
        XCTAssertTrue([_req.responseData isEqualToData:originalData]);
    }];
}

- (void)testShareCacheUsingSavedData {
    YTKCustomCacheRequest *req1 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get?key1=value1" cacheTimeInSeconds:10];
    YTKCustomCacheRequest *req2 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get?key2=value2" cacheTimeInSeconds:10];
    YTKCustomCacheRequest *req3 = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get?key3=value3" cacheTimeInSeconds:10];

    [self expectSuccess:req1 withAssertion:^(YTKBaseRequest *request) {
        [req2 saveResponseDataToCacheFile:request.responseData];
        [req3 saveResponseDataToCacheFile:request.responseData];
    }];

    // Check if shared cache works
    [self expectSuccess:req2 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        XCTAssertTrue(_req.isDataFromCache);

        NSDictionary<NSString *, NSString *> *responseArgs = _req.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs[@"key1"] isEqualToString:@"value1"]);
    }];

    [self expectSuccess:req3 withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        XCTAssertTrue(_req.isDataFromCache);

        NSDictionary<NSString *, NSString *> *responseArgs = _req.responseJSONObject[@"args"];
        XCTAssertTrue([responseArgs[@"key1"] isEqualToString:@"value1"]);
    }];
}

- (void)testCacheDirFilter {
    NSString *const pathSuffix = @"MyCachePath";
    // Add filter.
    YTKBasicCacheDirFilter *filter = [YTKBasicCacheDirFilter filterWithPathComponent:pathSuffix];
    [[YTKNetworkConfig sharedConfig] addCacheDirPathFilter:filter];

    // Test caching logic.
    YTKCustomCacheRequest *req = [[YTKCustomCacheRequest alloc] initWithRequestUrl:@"get" cacheTimeInSeconds:5 cacheVersion:0 cacheSensitiveData:nil];
    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // First time. Data should not be from cache.
        XCTAssertFalse(_req.isDataFromCache);
    }];

    [self expectSuccess:req withAssertion:^(YTKBaseRequest *request) {
        YTKRequest *_req = (YTKRequest *)request;
        // This time data should be from cache.
        XCTAssertTrue(_req.isDataFromCache);
    }];

    NSString *cachePath = [req cacheBasePath];
    NSFileManager* fileManager = [[NSFileManager alloc] init];

    // Test if new path is used.
    BOOL isDir;
    BOOL pathExists = [fileManager fileExistsAtPath:cachePath isDirectory:&isDir];
    XCTAssertTrue(pathExists);
    XCTAssertTrue(isDir);
    XCTAssertTrue([cachePath hasSuffix:pathSuffix]);

    // Clean up.
    [self clearDirectory:cachePath];
}

@end
