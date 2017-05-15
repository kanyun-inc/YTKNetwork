//
//  YYBaseResponseData.h
//  Pods
//
//  Created by 麦 芽糖 on 2017/5/15.
//
//

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel/YYModel.h>
#else
#import "YYModel.h"
#endif

@interface YYBaseResponseData : NSObject

@property (nonatomic, assign) NSInteger code; //服务器状态码，200正常
@property (nonatomic, copy) NSString *msg; //服务器透传信息
@property (nonatomic, strong) id data; //数据

@end
