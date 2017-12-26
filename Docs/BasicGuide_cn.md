YTKNetwork 使用基础教程
=====================

本教程将讲解 YTKNetwork 的基本功能的使用。


## YTKNetwork 基本组成

YTKNetwork 包括以下几个基本的类：

 * YTKNetworkConfig 类：用于统一设置网络请求的服务器和 CDN 的地址。
 * YTKRequest 类：所有的网络请求类需要继承于 `YTKRequest` 类，每一个 `YTKRequest` 类的子类代表一种专门的网络请求。

接下来我们详细地来解释这些类以及它们的用法。

### YTKNetworkConfig 类

YTKNetworkConfig 类有两个作用：

 1. 统一设置网络请求的服务器和 CDN 的地址。
 2. 管理网络请求的 YTKUrlFilterProtocol 实例（在[高级功能教程](ProGuide_cn.md) 中有介绍）。

我们为什么需要统一设置服务器地址呢？因为：

 1. 按照设计模式里的 `Do Not Repeat Yourself` 原则，我们应该把服务器地址统一写在一个地方。
 2. 在实际业务中，我们的测试人员需要切换不同的服务器地址来测试。统一设置服务器地址到 YTKNetworkConfig 类中，也便于我们统一切换服务器地址。
 
具体的用法是，在程序刚启动的回调中，设置好 YTKNetworkConfig 的信息，如下所示：

```objectivec
- (BOOL)application:(UIApplication *)application 
   didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
   config.baseUrl = @"http://yuantiku.com";
   config.cdnUrl = @"http://fen.bi";
}
```

设置好之后，所有的网络请求都会默认使用 YTKNetworkConfig 中 `baseUrl` 参数指定的地址。

大部分企业应用都需要对一些静态资源（例如图片、js、css）使用 CDN。YTKNetworkConfig 的 `cdnUrl` 参数用于统一设置这一部分网络请求的地址。

当我们需要切换服务器地址时，只需要修改 YTKNetworkConfig 中的 `baseUrl` 和 `cdnUrl` 参数即可。

### YTKRequest 类

YTKNetwork 的基本的思想是把每一个网络请求封装成对象。所以使用 YTKNetwork，你的每一种请求都需要继承 YTKRequest 类，通过覆盖父类的一些方法来构造指定的网络请求。把每一个网络请求封装成对象其实是使用了设计模式中的 Command 模式。

每一种网络请求继承 YTKRequest 类后，需要用方法覆盖（overwrite）的方式，来指定网络请求的具体信息。如下是一个示例：

假如我们要向网址 `http://www.yuantiku.com/iphone/register` 发送一个 `POST` 请求，请求参数是 username 和 password。那么，这个类应该如下所示：

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
    // “ http://www.yuantiku.com ” 在 YTKNetworkConfig 中设置，这里只填除去域名剩余的网址信息
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

在上面这个示例中，我们可以看到：

 * 我们通过覆盖 YTKRequest 类的 `requestUrl` 方法，实现了指定网址信息。并且我们只需要指定除去域名剩余的网址信息，因为域名信息在 YTKNetworkConfig 中已经设置过了。
 * 我们通过覆盖 YTKRequest 类的 `requestMethod` 方法，实现了指定 POST 方法来传递参数。
 * 我们通过覆盖 YTKRequest 类的 `requestArgument` 方法，提供了 POST 的信息。这里面的参数 `username` 和 `password` 如果有一些特殊字符（如中文或空格），也会被自动编码。
 
## 调用 RegisterApi

在构造完成 RegisterApi 之后，具体如何使用呢？我们可以在登录的 ViewController 中，调用 RegisterApi，并用 block 的方式来取得网络请求结果：

```objectivec
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

注意：你可以直接在 block 回调中使用 `self`，不用担心循环引用。因为 YTKRequest 会在执行完 block 回调之后，将相应的 block 设置成 nil。从而打破循环引用。

除了 block 的回调方式外，YTKRequest 也支持 delegate 方式的回调：

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

## 验证服务器返回内容

有些时候，由于服务器的 Bug，会造成服务器返回一些不合法的数据，如果盲目地信任这些数据，可能会造成客户端 Crash。如果加入大量的验证代码，又使得编程体力活增加，费时费力。

使用 YTKRequest 的验证服务器返回值功能，可以很大程度上节省验证代码的编写时间。

例如，我们要向网址 `http://www.yuantiku.com/iphone/users` 发送一个 `GET` 请求，请求参数是 `userId` 。我们想获得某一个用户的信息，包括他的昵称和等级，我们需要服务器必须返回昵称（字符串类型）和等级信息（数值类型），则可以覆盖 `jsonValidator` 方法，实现简单的验证。

```objectivec
- (id)jsonValidator {
    return @{
        @"nick": [NSString class],
        @"level": [NSNumber class]
    };
}
```

完整的代码如下：

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

以下是更多的 jsonValidator 的示例：

 * 要求返回 String 数组：

```objectivec
- (id)jsonValidator {
    return @[ [NSString class] ];
}
```

 * 来自猿题库线上环境的一个复杂的例子：
 
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


## 使用 CDN 地址

如果要使用 CDN 地址，只需要覆盖 YTKRequest 类的 `- (BOOL)useCDN;` 方法。

例如我们有一个取图片的接口，地址是 `http://fen.bi/image/imageId` ，则我们可以这么写代码 :

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

## 断点续传

要启动断点续传功能，只需要覆盖 `resumableDownloadPath` 方法，指定断点续传时文件的存储路径即可，文件会被自动保存到此路径。如下代码将刚刚的取图片的接口改造成了支持断点续传：

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

## 按时间缓存内容

刚刚我们写了一个 GetUserInfoApi ，这个网络请求是获得用户的一些资料。

我们想像这样一个场景，假设你在完成一个类似微博的客户端，GetUserInfoApi 用于获得你的某一个好友的资料，因为好友并不会那么频繁地更改昵称，那么短时间内频繁地调用这个接口很可能每次都返回同样的内容，所以我们可以给这个接口加一个缓存。

在如下示例中，我们通过覆盖 `cacheTimeInSeconds` 方法，给 GetUserInfoApi 增加了一个 3 分钟的缓存，3 分钟内调用调 Api 的 start 方法，实际上并不会发送真正的请求。

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
    // 3 分钟 = 180 秒
    return 60 * 3;
}

@end
```

该缓存逻辑对上层是透明的，所以上层可以不用考虑缓存逻辑，每次调用 GetUserInfoApi 的 start 方法即可。GetUserInfoApi 只有在缓存过期时，才会真正地发送网络请求。

以上几个示例代码在 Demo 工程中也可获得。
