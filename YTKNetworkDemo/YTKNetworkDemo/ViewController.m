//
//  ViewController.m
//  YTKNetworkDemo
//
//  Created by Chenyu Lan on 10/28/14.
//  Copyright (c) 2014 yuantiku.com. All rights reserved.
//

#import "ViewController.h"
#import "YTKBatchRequest.h"
#import "YTKChainRequest.h"
#import "GetImageApi.h"
#import "GetUserInfoApi.h"
#import "RegisterApi.h"
#import "YTKBaseRequest+AnimatingAccessory.h"
#import <CommonCrypto/CommonDigest.h>

@interface ViewController ()<YTKChainRequestDelegate>

@end

@implementation ViewController

//http://smres.qudu99.com/site-503(new)/1/113523/coverbig.jpg
//http://smres.qudu99.com/site-532(new)/0/10/coverbig.jpg
//http://smres.qudu99.com/site-519(new)/3/307145/coverbig.jpg

- (NSString *)MD5:(NSString *)mdStr
{
    const char *original_str = [mdStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

/// Send batch request
- (void)sendBatchRequest {
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"site-503(new)/1/113523/coverbig.jpg"];
    GetImageApi *b = [[GetImageApi alloc] initWithImageId:@"site-532(new)/0/10/coverbig.jpg"];
    GetImageApi *c = [[GetImageApi alloc] initWithImageId:@"site-519(new)/3/307145/coverbig.jpg"];
//    GetUserInfoApi *d = [[GetUserInfoApi alloc] initWithUserId:@"123"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[a, b, c]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        NSLog(@"succeed");
        NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
        
        NSArray *requests = batchRequest.requestArray;
        for (NSInteger i = 0; i < 3; i++)
        {
            GetImageApi *imgAPI = (GetImageApi *)requests[i];
            NSString *filePath = [cachePath stringByAppendingPathComponent:[self MD5:imgAPI.imageId]];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            UIImageView *imageView = [self.view viewWithTag:1000+i];
            imageView.image = image;
        }
    } failure:^(YTKBatchRequest *batchRequest) {
        NSLog(@"failed");
    }];
}

- (void)sendChainRequest {
//    RegisterApi *reg = [[RegisterApi alloc] initWithUsername:@"username" password:@"password"];
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"site-503(new)/1/113523/coverbig.jpg"];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:a callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        
        NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
        GetImageApi *imgAPI = (GetImageApi *)baseRequest;
        NSString *filePath = [cachePath stringByAppendingPathComponent:[self MD5:imgAPI.imageId]];
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        UIImageView *imageView = [self.view viewWithTag:1000+3];
        imageView.image = image;

        GetImageApi *b = [[GetImageApi alloc] initWithImageId:@"site-532(new)/0/10/coverbig.jpg"];
        [chainRequest addRequest:b callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
            
            NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
            GetImageApi *imgAPI = (GetImageApi *)baseRequest;
            NSString *filePath = [cachePath stringByAppendingPathComponent:[self MD5:imgAPI.imageId]];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            UIImageView *imageView = [self.view viewWithTag:1000+4];
            imageView.image = image;
            
            GetImageApi *c = [[GetImageApi alloc] initWithImageId:@"site-519(new)/3/307145/coverbig.jpg"];
            [chainRequest addRequest:c callback:^(YTKChainRequest * _Nonnull chainRequest, YTKBaseRequest * _Nonnull baseRequest) {
                
                NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
                GetImageApi *imgAPI = (GetImageApi *)baseRequest;
                NSString *filePath = [cachePath stringByAppendingPathComponent:[self MD5:imgAPI.imageId]];
                UIImage *image = [UIImage imageWithContentsOfFile:filePath];
                UIImageView *imageView = [self.view viewWithTag:1000+5];
                imageView.image = image;
            }];
        }];
        
    }];
    chainReq.delegate = self;
    // start to send request
    [chainReq start];
}

- (void)chainRequestFinished:(YTKChainRequest *)chainRequest {
    // all requests are done
    
}

- (void)chainRequestFailed:(YTKChainRequest *)chainRequest failedBaseRequest:(YTKBaseRequest*)request {
    // some one of request is failed
}

- (void)loadCacheData {
    NSString *userId = @"1";
    GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
    if ([api cacheJson]) {
        NSDictionary *json = [api cacheJson];
        NSLog(@"json = %@", json);
        // show cached data
    }

    api.animatingText = @"正在加载";
    api.animatingView = self.view;

    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSLog(@"update ui");
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"failed");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    for (NSInteger i = 0; i < 3; i ++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5/2+125*i, 64, 120, 160)];
        imgView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:imgView];
        imgView.tag = 1000+i;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn];
    [btn setTitle:@"sendBatchRequest" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.frame = CGRectMake(10, 64+160+20, 150, 20);
    [btn addTarget:self action:@selector(sendBatchRequest) forControlEvents:UIControlEventTouchUpInside];
    
    for (NSInteger i = 0; i < 3; i ++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5/2+125*i, 64+160+20+20+20, 120, 160)];
        imgView.backgroundColor = [UIColor grayColor];
        [self.view addSubview:imgView];
        imgView.tag = 1000+i+3;
    }
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:btn2];
    [btn2 setTitle:@"sendChainRequest" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn2 setBackgroundColor:[UIColor redColor]];
    btn2.frame = CGRectMake(10, 64+160+20+20+160+20+20, 150, 20);
    [btn2 addTarget:self action:@selector(sendChainRequest) forControlEvents:UIControlEventTouchUpInside];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
