YTKNetwork Basic Guide 
======================

In the article, we will introduce the basic usage of YTKNetwork.

## YTKNetwork's basic composition

YTKNetwork mainly contains the following classes:

 * YTKNetworkConfig ：it's used for setting global network host address and CDN address.
 * YTKRequest ：it's the parent of all the detailed network request classes. All network request classes should inherit it. Every subclass of `YTKRequest` represents a specific network request.

We will explain the above 2 classes' detailed usage below.

### YTKNetworkConfig class

YTKNetworkConfig class has 2 usages:

 1. Set global network host address and CDN address.
 2. Manage the filters which implemented `YTKUrlFilterProtocol` protocol（we will discuss it in pro usage guide）。

We use YTKNetworkConfig to set global network host address because:

 1. According to the `Do Not Repeat Yourself` principle，we should write the host address only once.
 2. In practise, our testers need to switch host addresses at runtime. YTKNetworkConfig can satisfy such requirement.
 
We should set YTKNetworkConfig's property at the beggining of app launching, the sample is below:

```objectivec
- (BOOL)application:(UIApplication *)application 
   didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
   config.baseUrl = @"http://yuantiku.com";
   config.cdnUrl = @"http://fen.bi";
}
```

After setting, all network requests will use YTKNetworkConfig's `baseUrl` property as their host addresses, and they will use the `cdnUrl` property of YTKNetworkConfig as their CDN addresses.

If we want to switch server address, we can just change YTKNetworkConfig's `baseUrl` property.

### YTKRequest class

The design idea of YTKNetwork is that every specific network request should be a object. So after using YTKNetwork, all your request classes should inherit YTKNetwork. Through overwriting the methods of super class, you can build your own specific and distinguished request. The key idea behind this is somewhat like the Command pattern.

For example, if we want to send a POST request to `http://www.yuantiku.com/iphone/register`，with username and password as arguments, then the class should be as following:：

```objectivec
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
    return YTKRequestMethodPOST;
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

 * Through overwriting `requestUrl` method, we've indicated the detailed url. Bacause host address has been set in `YTKNetworkConfig`, we should not write the host address in `requestUrl` method.
 * Through overwriting `requestMethod` method, we've indicated the use of the `POST` method.
 * Through overwriting `requestArgument` method, we've provided the `POST` data. If arguments `username` and `password` contain any charaters which should be escaped, the library will do it automatically.
 
## Call RegisterApi

OK, how can we use the `RegisterApi`? We can call it in the login view controller. After initializing the instance, we can call its `start` or `startWithCompletionBlockWithSuccess` method to send the request to the network request queue.

Then we can get network response by `block` or `delegate` mechanism.

```objectivec
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

Kindly be noted that you can use `self` directly in the block where the retain cycle won't happen. Because YTKRequest will set callback block to nil, so the block will be released right after the network request completed.

Besides the `block` callback, YTKRequest also support `delegate` callback method. The example is below:

```objectivec
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

The response JSON from the server cannnot be always trusted. Client may crash if the data is returned in faulty format from the server. 

YTKRequest provides a simple way to verity the respose JSON.

For example, let's say we need to send a `GET` request to `http://www.yuantiku.com/iphone/users` address with a argument named `userId`. The server will return the target user's information, including nickname and level. We shall guarantee that the response type of nickname is string and the type of level is number. To ensure this, we can overwrite the `jsonValidator` as following:

```objectivec
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}
```

The whole code sample is below:

```objectivec
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

```objectivec
- (id)jsonValidator {
    return @[ [NSString class] ];
}
```

 * Here is one complex sample from our company:
 
```objectivec
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

If you need to use CDN address in some of your requests, just overwrite the `- (BOOL)useCDN;` method, and return `YES` in the method.

For example, if we have a interface for image downloading, and the address is `http://fen.bi/image/imageId` with the host `http://fen.bi` as the CDN address. Then the code should be below:

```objectivec
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

If you want to enable resumable downloading, you just need to overwrite the  `resumableDownloadPath` method and provide a the path you want to save the downloaded file. The file will be automatically saved to that path.

We can modify above example to support resumable downloading.

```objectivec
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
 
We've implemented the `GetUserInfoApi` before, which is used for getting user information. 

We may want to cache the response. In the following example, we overwrite  the `cacheTimeInSeconds` method, then our API will automatically cache data for specified amount of time. If the cached data is not expired, the api's `start` and `startWithCompletionBlockWithSuccess` will return cached data as a result directly.

```objectivec
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
    // cache 3 minutes, which is 60 * 3 = 180 seconds
    return 60 * 3;
}

@end
```

The cache mechanism is transparent to the controller, which means the request caller may get the result right after invoking the request without casuing any real network traffic as long as its cached data remains valid.

The above code samples are available in the YTKNetworkDemo project.
