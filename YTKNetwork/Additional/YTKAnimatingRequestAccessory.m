//
//  YTKAnimatingRequestAccessory.m
//  Ape_uni
//
//  Created by Chenyu Lan on 10/30/14.
//  Copyright (c) 2014 Fenbi. All rights reserved.
//

#import "YTKAnimatingRequestAccessory.h"
#import "MBProgressHUD.h"

@implementation YTKAnimatingRequestAccessory

- (id)initWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    self = [super init];
    if (self) {
        _animatingView = animatingView;
        _animatingText = animatingText;
    }
    return self;
}

- (id)initWithAnimatingView:(UIView *)animatingView {
    self = [super init];
    if (self) {
        _animatingView = animatingView;
    }
    return self;
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView {
    return [[self alloc] initWithAnimatingView:animatingView];
}

+ (id)accessoryWithAnimatingView:(UIView *)animatingView animatingText:(NSString *)animatingText {
    return [[self alloc] initWithAnimatingView:animatingView animatingText:animatingText];
}

- (void)requestWillStart:(id)request {
    if (_animatingView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *shownMessage = _animatingText != nil ? _animatingText : @"正在加载";
            [MBProgressHUD hideAllHUDsForView:_animatingView animated:NO];
            MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:_animatingView animated:YES];
            HUD.layer.zPosition = 999;
            if (shownMessage.length > 0) {
                HUD.labelText = shownMessage;
            }
        });
    }
}

- (void)requestWillStop:(id)request {
    if (_animatingView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:_animatingView animated:YES];
        });
    }
}

@end
