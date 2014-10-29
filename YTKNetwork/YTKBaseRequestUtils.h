//
//  FenbiBaseRequestUtils.h
//  Solar
//
//  Created by tangqiao on 8/6/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTKBaseRequestUtils : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;
+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString appendParameters:(NSDictionary *)parameters;

@end
