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

//成功
#define kSuccessCode 200
//余额不足
#define kMoneyNotEnoughCode 9

@interface YYBaseResponseData : NSObject

@property (nonatomic, assign) NSInteger code; //服务器状态码，200正常
@property (nonatomic, copy) NSString *msg; //服务器透传信息
@property (nonatomic, strong) id data; //数据

@property (nonatomic, assign, readonly, getter=isSuccess) BOOL isSuccess; //请求是否成功
@property (nonatomic, assign, readonly, getter=isMoneyNotEnough) BOOL isMoneyNotEnough; //是否是余额不足

@end
