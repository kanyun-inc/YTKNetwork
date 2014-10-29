//
//  FenbiBaseRequestUtils.h
//  Solar
//
//  Created by tangqiao on 8/6/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define YTKLog(...)    NSLog(__VA_ARGS__)
#else
#define YTKLog(...)
#endif

@interface YTKNetworkPrivate : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

@end

