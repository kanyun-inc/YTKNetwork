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

 * 我们通过覆盖 YTKRequest 类的 `requestUrl`方法，实现了指定网址信息。并且我们只需要指定除去域名剩余的网址信息，因为域名信息在 YTKNetworkConfig 中已经设置过了。
 * 我们通过覆盖 YTKRequest 类的 `requestMethod`方法，实现了指定 POST 方法来传递参数。
 * 我们通过覆盖 YTKRequest 类的 `requestArgument`方法，提供了 POST 的信息。这里面的参数 `username` 和 `password` 如果有一些特殊字符（如中文或空格），也会被自动编码。
 
## 调用 RegisterApi

在构造完成 RegisterApi 之后，具体如何使用呢？我们可以在登录的 ViewController中，调用 RegisterApi，并用block的方式来取得网络请求结果：

```
- (void)loginButtonPressed:(id)sender {
    NSString *username = self.UserNameTextField.text;
    NSString *password = self.PasswordTextField.text;
    if (username.length > 0 && password.length > 0) {
        RegisterApi *api = [[RegisterApi alloc] initWithUsername:username password:password];
        [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            // 你可以直接在这里使用 self
            NSLog(@"succeed");
            
        } failure:^(YTKBaseRequest *request) {
            // 你可以直接在这里使用 self
            NSLog(@"failed");
        }];
    }
}

```

注意：你可以直接在block回调中使用 `self`，不用担心循环引用。因为 YTKRequest 会在执行完 block 回调之后，将相应的 block 设置成 nil。从而打破循环引用。

除了block的回调方式外，YTKRequest 也支持 delegate 方式的回调：

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

## 验证服务器返回内容

有些时候，由于服务器的Bug，会造成服务器返回一些不合法的数据，如果盲目地信任这些数据，可能会造成客户端Crash。如果加入大量的验证代码，又使得编程体力活增加，费时费力。

使用 YTKRequest 的验证服务器返回值功能，可以很大程度上节省验证代码的编写时间。

例如，我们要向网址 `http://www.yuantiku.com/iphone/users` 发送一个`GET`请求，请求参数是 `userId` 。我们想获得某一个用户的信息，包括他的昵称和等级，我们需要服务器必须返回昵称（字符串类型）和等级信息（数值类型），则可以覆盖`jsonValidator`方法，实现简单的验证。

```
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}
```

完整的代码如下：

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

以下是更多的jsonValidator的示例：

 * 要求返回String数组：

```
- (id)jsonValidator {
    return @[ [NSString class] ];
}
```

 * 来自猿题库线上环境的一个复杂的例子：
 
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


## 使用CDN地址

如果要使用CDN地址，只需要覆盖 YTKRequest 类的 `- (BOOL)useCDN;`方法。

例如我们有一个取图片的接口，地址是 `http://fen.bi/image/imageId` ，则我们可以这么写代码:

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

## 断点续传

要启动断点续传功能，只需要覆盖 `resumableDownloadPath`方法，指定断点续传时文件的暂存路径即可。如下代码将刚刚的取图片的接口改造成了支持断点续传：

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

## 按时间缓存内容

刚刚我们写了一个 GetUserInfoApi ，这个网络请求是获得用户的一些资料。

我们想像这样一个场景，假设你在完成一个类似微博的客户端，GetUserInfoApi 用于获得你的某一个好友的资料，因为好友并不会那么频繁地更改昵称，那么短时间内频繁地调用这个接口很可能每次都返回同样的内容，所以我们可以给这个接口加一个缓存。

在如下示例中，我们通过覆盖 `cacheTimeInSeconds`方法，给 GetUserInfoApi 增加了一个3分钟的缓存，3分钟内调用调Api的start方法，实际上并不会发送真正的请求。

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

该缓存逻辑对上层是透明的，所以上层可以不用考虑缓存逻辑，每次调用 GetUserInfoApi 的start方法即可。GetUserInfoApi只有在缓存过期时，才会真正地发送网络请求。

以上几个示例代码在Demo工程中也可获得。
