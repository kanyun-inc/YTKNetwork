//
//  YTKRequestConcurrencyTest.m
//  YTKNetwork
//
//  Created by skyline on 16/8/3.
//  Copyright © 2016年 skyline. All rights reserved.
//

#import "YTKTestCase.h"
#import "YTKBasicHTTPRequest.h"
#import "YTKNetworkPrivate.h"

@interface YTKConcurrencyTest : YTKTestCase

@end

@implementation YTKConcurrencyTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicConcurrentRequestCreation {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);

    NSInteger dispatchTarget = 1000;
    __block NSInteger completionCount = 0;
    __block NSInteger callbackCount = 0;
    for (NSUInteger i = 0; i < dispatchTarget; i++) {
        dispatch_async(queue, ^{
            @autoreleasepool {
                YTKBasicHTTPRequest *req = [[YTKBasicHTTPRequest alloc] init];
                req.tag = i;

                [req startWithCompletionBlockWithSuccess:nil failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                    // Left is from callback, right is captured by block.
                    XCTAssertTrue(request.tag == i);
                    callbackCount ++;
                }];

                // We just need to simulate concurrent request creation here.
                [req.requestTask cancel];

                NSLog(@"Current req number: %zd", i);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    completionCount++;
                });
            }
        });
    }

    while (callbackCount < dispatchTarget) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }

    XCTAssertTrue(completionCount == callbackCount);
}

@end
