//
//  YYBaseResponseData.m
//  Pods
//
//  Created by 麦 芽糖 on 2017/5/15.
//
//

#import "YYBaseResponseData.h"

@interface YYBaseResponseData ()

@property (nonatomic, assign) BOOL isSuccess; //请求是否成功

@end

@implementation YYBaseResponseData

- (BOOL)isSuccess {
    return self.code == kSuccessCode;
}

- (BOOL)isMoneyNotEnough {
    return self.code == kMoneyNotEnoughCode;
}

@end
