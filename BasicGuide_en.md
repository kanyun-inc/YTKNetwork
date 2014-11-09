YTKNetwork Basic Guide 
===

In the article, we will introduce the basic usage of YTKNetwork.

## YTKNetwork's basic composition

YTKNetwork mainly contains the following classes:

 * YTKNetworkConfig ：it's used for setting global network host address and CDN address.
 * YTKRequest 类：it's the parent of all the detailed network request class. All network request class should extend it. Every subclass of `YTKRequest` stands a specific network request.

We will explain the ablow 2 classes' detail usage below.

### YTKNetworkConfig class

YTKNetworkConfig class has 2 usage:

 1. Set global network host address and CDN address.
 2. Manage the filters which implement `YTKUrlFilterProtocol` protocol（we will discuss it in pro usage guide）。

We usage YTKNetworkConfig to set global network host address because:

 1. According the `Do Not Repeat Yourself` principle，we should write the host address only once.
 2. In practise, our tester need switch host address at runtime. YTKNetworkConfig can satisfy this requirement.
 
We should set YTKNetworkConfig's property at the beggining of app launching, the sample is below:

```
- (BOOL)application:(UIApplication *)application 
   didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   YTKNetworkConfig *config = [YTKNetworkConfig sharedInstance];
   config.baseUrl = @"http://yuantiku.com";
   config.cdnUrl = @"http://fen.bi";
}
```
After setting, all network request will use YTKNetworkConfig's `baseUrl` property as its host address. And they will use  YTKNetworkConfig's `cdnUrl` property as CDN address.

If we want switch server address, we can just change YTKNetworkConfig's `baseUrl` property.

### YTKRequest class

YTKNetwork's design idea is that every specific network request should be a object. So after using YTKNetwork, all your request class should extend YTKNetwork. Through overwrite some super's method, you can build your every different request. It just like the Command pattern.

For example, if we want to send a POST request to `http://www.yuantiku.com/iphone/register`，with username and password as arguments, then the class shoud be as following:：

```
// RegisterApi.h
#import "YTKRequest.h"

@interface RegisterApi : YTKRequest

- (id)initWithUsername:(NSString *)username password:(NSString *)password;

@end


// RegisterApi.m


#import "RegisterApi.h"

@implementation RegisterApi {
    NSString *_username;
    NSString *_password;
}

- (id)initWithUsername:(NSString *)username password:(NSString *)password {
    self = [super init];
    if (self) {
        _username = username;
        _password = password;
    }
    return self;
}

- (NSString *)requestUrl {
    // “http://www.yuantiku.com” is set in YTKNetworkConfig, so we ignore it
    return @"/iphone/register";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPost;
}

- (id)requestArgument {
    return @{
        @"username": _username,
        @"password": _password
    };
}

@end

```

In above example:

 * Through overwriting `requestUrl` method, we've indicate the detailed url. Bacause host address is set in `YTKNetworkConfig`, we should not write the host address in `requestUrl` method.
 * Through overwriting `requestMethod` method, we've indicate to use the `POST` method.
 * Through overwriting `requestArgument` method, we've provided the `POST` data. If the argument  `username` and `password` contain any charaters which should be escaped, the library will do it automatically.
 
## Call RegisterApi

OK, how can we use the `RegisterApi`? We can call it in the login view controller. After initialize the instance, we can all its `start` or `startWithCompletionBlockWithSuccess` method to send the request to the network request queue.

Then we can get network response by `block` or `delegate` mechanism.

```
- (void)loginButtonPressed:(id)sender {
    NSString *username = self.UserNameTextField.text;
    NSString *password = self.PasswordTextField.text;
    if (username.length > 0 && password.length > 0) {
        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            // you can use self here, retain cycle won't happen
            NSLog(@"succeed");
            
        } failure:^(YTKBaseRequest *request) {
            // you can use self here, retain cycle won't happen
            NSLog(@"failed");
        }];
    }
}

```

Please pay attention, you can use `self` directly in block, retain cycle won't happen. Because YTKRequest will set callback block to nil, so the block will be released right after the network request completed.

Beside the `block` callback, YTKRequest also support `delegate` callback method. The example is below:

```
- (void)loginButtonPressed:(id)sender {
    NSString *username = self.UserNameTextField.text;
    NSString *password = self.PasswordTextField.text;
    if (username.length > 0 && password.length > 0) {
        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
        api.delegate = self;
        [api start];
    }
}

- (void)requestFinished:(YTKBaseRequest *)request {
    NSLog(@"succeed");
}

- (void)requestFailed:(YTKBaseRequest *)request {
    NSLog(@"failed");
}
```

## Verify response JSON

Server's response JSON is not always trusted. Client may crash if some error data format is returned from server. 

YTKRequest provides a simple way to verity respose JSON.

For example, we need to send a `GET` request to `http://www.yuantiku.com/iphone/users` address, with a argument named `userId`. Server will return the target user's information, including nickname and level. We want to guarantee the response type must be string type(nickname) and number type(level). We can overwrite the `jsonValidator` as the following:

```
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}
```

The whole code sample is below:

```
// GetUserInfoApi.h
#import "YTKRequest.h"

@interface GetUserInfoApi : YTKRequest

- (id)initWithUserId:(NSString *)userId;

@end


// GetUserInfoApi.m
#import "GetUserInfoApi.h"

@implementation GetUserInfoApi {
    NSString *_userId;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{ @"id": _userId };
}

- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}

@end

```

Here is some other samples：

 * Require return String array:

```
- (id)jsonValidator {
    return @[ [NSString class] ];
}
```

 * Here is one complex sample from our company:
 
```
- (id)jsonValidator {
    return @[@{
        @"id": [NSNumber class],
        @"imageId": [NSString class],
        @"time": [NSNumber class],
        @"status": [NSNumber class],
        @"question": @{
            @"id": [NSNumber class],
            @"content": [NSString class],
            @"contentType": [NSNumber class]
        }
    }];
} 
```


## Use CDN address

If you need to use CDN address in some of your request, just need to overwrite the `- (BOOL)useCDN;` method, and return `YES` in the method.

For example, if we have a download image inteface, the address is  `http://fen.bi/image/imageId`, the host `http://fen.bi` is a CDN address. Then the code should be below:

```
// GetImageApi.h
#import "YTKRequest.h"

@interface GetImageApi : YTKRequest
- (id)initWithImageId:(NSString *)imageId;
@end

// GetImageApi.m
#import "GetImageApi.h"

@implementation GetImageApi {
    NSString *_imageId;
}

- (id)initWithImageId:(NSString *)imageId {
    self = [super init];
    if (self) {
        _imageId = imageId;
    }
    return self;
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"/iphone/images/%@", _imageId];
}

- (BOOL)useCDN {
    return YES;
}

@end
```

## Resumable Downloading

If you want to enable resumable downloading, you just need to overwrite the  `resumableDownloadPath` method and provide a temporary to save the downloading data.

We can modify above example to support resumable downloading.

```
@implementation GetImageApi {
    NSString *_imageId;
}

- (id)initWithImageId:(NSString *)imageId {
    self = [super init];
    if (self) {
        _imageId = imageId;
    }
    return self;
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"/iphone/images/%@", _imageId];
}

- (BOOL)useCDN {
    return YES;
}

- (NSString *)resumableDownloadPath {
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [libPath stringByAppendingPathComponent:@"Caches"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:_imageId];
    return filePath;
}

@end
```

## Cache response data

Just now we've implemented a `GetUserInfoApi`, which is used for get user information. 

We may want to cache the response, in the following example, we overwrite  `cacheTimeInSeconds` method, then our API will automatically cache data by time. If the time is not expired, the api's `start` and `startWithCompletionBlockWithSuccess` will return directly and return cached data as a result.

```
@implementation GetUserInfoApi {
    NSString *_userId;
}

- (id)initWithUserId:(NSString *)userId {
    self = [super init];
    if (self) {
        _userId = userId;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/iphone/users";
}

- (id)requestArgument {
    return @{ @"id": _userId };
}

- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}

- (NSInteger)cacheTimeInSeconds {
    // 3分钟 = 180 秒
    return 60 * 3;
}

@end
```

The cache logic is totally transparent for the controller, so the request caller can send request every time, request will not actually send if cache is not expired.

The above code samples are available in the YTKNetworkDemo project.
