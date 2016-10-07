//
//  YTKPerformanceTests.m
//  YTKNetwork
//
//  Created by skyline on 16/8/3.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKBasicHTTPRequest.h"

@interface YTKPerformanceTests : YTKTestCase

@end

@implementation YTKPerformanceTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBaseRequestCreationPerformance {
    NSInteger targetCount = 1000;
    // The measure block will be called several times.
    [self measureBlock:^{
        for (NSUInteger i = 0; i < targetCount; i++) {
            @autoreleasepool {
                YTKBasicHTTPRequest *req = [[YTKBasicHTTPRequest alloc] init];
                [req startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
                    NSNumber *result = request.responseObject;
                    XCTAssertTrue([result isEqualToNumber:@(i)]);
                } failure:nil];
                [req.requestTask cancel];
            }
        }
    }];
}

@end
