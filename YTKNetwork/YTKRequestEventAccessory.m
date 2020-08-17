//
//  YTKRequestEventAccessory.m
//  YTKNetwork
//
//  Created by Chuanren Shang on 2020/8/17.
//

#import "YTKRequestEventAccessory.h"

@implementation YTKRequestEventAccessory

- (void)requestWillStart:(id)request {
    if (self.willStartBlock != nil) {
        self.willStartBlock(request);
        self.willStartBlock = nil;
    }
}

- (void)requestWillStop:(id)request {
    if (self.willStopBlock != nil) {
        self.willStopBlock(request);
        self.willStopBlock = nil;
    }
}

- (void)requestDidStop:(id)request {
    if (self.didStopBlock != nil) {
        self.didStopBlock(request);
        self.didStopBlock = nil;
    }
}

@end

@implementation YTKBaseRequest (YTKRequestEventAccessory)

- (void)startWithWillStart:(nullable YTKRequestCompletionBlock)willStart
                  willStop:(nullable YTKRequestCompletionBlock)willStop
                   success:(nullable YTKRequestCompletionBlock)success
                   failure:(nullable YTKRequestCompletionBlock)failure
                   didStop:(nullable YTKRequestCompletionBlock)didStop {
    YTKRequestEventAccessory *accessory = [YTKRequestEventAccessory new];
    accessory.willStartBlock = willStart;
    accessory.willStopBlock = willStop;
    accessory.didStopBlock = didStop;
    [self addAccessory:accessory];
    [self startWithCompletionBlockWithSuccess:success
                                      failure:failure];
}

@end

@implementation YTKBatchRequest (YTKRequestEventAccessory)

- (void)startWithWillStart:(nullable void (^)(YTKBatchRequest *batchRequest))willStart
                  willStop:(nullable void (^)(YTKBatchRequest *batchRequest))willStop
                   success:(nullable void (^)(YTKBatchRequest *batchRequest))success
                   failure:(nullable void (^)(YTKBatchRequest *batchRequest))failure
                   didStop:(nullable void (^)(YTKBatchRequest *batchRequest))didStop {
    YTKRequestEventAccessory *accessory = [YTKRequestEventAccessory new];
    accessory.willStartBlock = willStart;
    accessory.willStopBlock = willStop;
    accessory.didStopBlock = didStop;
    [self addAccessory:accessory];
    [self startWithCompletionBlockWithSuccess:success
                                      failure:failure];
}

@end
