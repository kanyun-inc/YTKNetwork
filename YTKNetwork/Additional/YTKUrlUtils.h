//
//  YTKUrlUtils.h
//  Pods
//
//  Created by skyline on 16/8/4.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTKUrlUtils : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary<NSString *, NSString *> *)parameters;

@end

NS_ASSUME_NONNULL_END
