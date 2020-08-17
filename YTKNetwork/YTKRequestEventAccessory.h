//
//  YTKRequestEventAccessory.h
//  YTKNetwork
//
//  Created by Chuanren Shang on 2020/8/17.
//

#import "YTKBaseRequest.h"
#import "YTKBatchRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YTKRequestEventAccessory : NSObject <YTKRequestAccessory>

@property (nonatomic, copy, nullable) void (^willStartBlock)(id);
@property (nonatomic, copy, nullable) void (^willStopBlock)(id);
@property (nonatomic, copy, nullable) void (^didStopBlock)(id);

@end

@interface YTKBaseRequest (YTKRequestEventAccessory)

- (void)startWithWillStart:(nullable YTKRequestCompletionBlock)willStart
                  willStop:(nullable YTKRequestCompletionBlock)willStop
                   success:(nullable YTKRequestCompletionBlock)success
                   failure:(nullable YTKRequestCompletionBlock)failure
                   didStop:(nullable YTKRequestCompletionBlock)didStop;

@end

@interface YTKBatchRequest (YTKRequestEventAccessory)

- (void)startWithWillStart:(nullable void (^)(YTKBatchRequest *batchRequest))willStart
                  willStop:(nullable void (^)(YTKBatchRequest *batchRequest))willStop
                   success:(nullable void (^)(YTKBatchRequest *batchRequest))success
                   failure:(nullable void (^)(YTKBatchRequest *batchRequest))failure
                   didStop:(nullable void (^)(YTKBatchRequest *batchRequest))didStop;

@end

NS_ASSUME_NONNULL_END
