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
    for (NSUInteger i = 0; i < dispatchTarget; i++) {
        dispatch_async(queue, ^{
            YTKBasicHTTPRequest *req = [[YTKBasicHTTPRequest alloc] init];
            [req startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
                NSNumber *result = request.responseObject;
                XCTAssertTrue([result isEqualToNumber:@(i)]);
            } failure:nil];
            // We just need to simulate concurrent request creation here.
            [req.requestTask cancel];

            YTKBaseRequest *mockedSuccessResult = [[YTKBaseRequest alloc] init];
            mockedSuccessResult.responseObject = @(i);
            req.successCompletionBlock(mockedSuccessResult);

            NSLog(@"Current req number: %zd", i);
            dispatch_sync(dispatch_get_main_queue(), ^{
                completionCount++;
            });
        });
    }

    while (completionCount < dispatchTarget) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

@end
