YTKNetwork 使用高级教程
=====================

本教程将讲解 YTKNetwork 的高级功能的使用。

## YTKUrlFilterProtocol 接口

YTKUrlFilterProtocol 接口用于实现对网络请求 URL 或参数的重写，例如可以统一为网络请求加上一些参数，或者修改一些路径。

例如：在猿题库中，我们需要为每个网络请求加上客户端的版本号作为参数。所以我们实现了如下一个 `YTKUrlArgumentsFilter` 类，实现了 `YTKUrlFilterProtocol` 接口 :

```objectivec
// YTKUrlArgumentsFilter.h
// 实现自己的 URL 拼接工具类
@interface YTKUrlArgumentsFilter : NSObject <YTKUrlFilterProtocol>

+ (YTKUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments;

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request;

@end


// YTKUrlArgumentsFilter.m
@implementation YTKUrlArgumentsFilter {
    NSDictionary *_arguments;
}

+ (YTKUrlArgumentsFilter *)filterWithArguments:(NSDictionary *)arguments {
    return [[self alloc] initWithArguments:arguments];
}

- (id)initWithArguments:(NSDictionary *)arguments {
    self = [super init];
    if (self) {
        _arguments = arguments;
    }
    return self;
}

- (NSString *)filterUrl:(NSString *)originUrl withRequest:(YTKBaseRequest *)request {
    return [YTKUrlArgumentsFilter urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
}

@end
```

通过以上 `YTKUrlArgumentsFilter` 类，我们就可以用以下代码方便地为网络请求增加统一的参数，如增加当前客户端的版本号：

```objectivec
- (BOOL)application:(UIApplication *)application 
         didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupRequestFilters];
    return YES;
}

- (void)setupRequestFilters {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
    YTKUrlArgumentsFilter *urlFilter = [YTKUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
    [config addUrlFilter:urlFilter];
}
```

## YTKBatchRequest 类

YTKBatchRequest 类：用于方便地发送批量的网络请求，YTKBatchRequest 是一个容器类，它可以放置多个 `YTKRequest` 子类，并统一处理这多个网络请求的成功和失败。

在如下的示例中，我们发送了 4 个批量的请求，并统一处理这 4 个请求同时成功的回调。

```objectivec
#import "YTKBatchRequest.h"
#import "GetImageApi.h"
#import "GetUserInfoApi.h"

- (void)sendBatchRequest {
    GetImageApi *a = [[GetImageApi alloc] initWithImageId:@"1.jpg"];
    GetImageApi *b = [[GetImageApi alloc] initWithImageId:@"2.jpg"];
    GetImageApi *c = [[GetImageApi alloc] initWithImageId:@"3.jpg"];
    GetUserInfoApi *d = [[GetUserInfoApi alloc] initWithUserId:@"123"];
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[a, b, c, d]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        NSLog(@"succeed");
        NSArray *requests = batchRequest.requestArray;
        GetImageApi *a = (GetImageApi *)requests[0];
        GetImageApi *b = (GetImageApi *)requests[1];
        GetImageApi *c = (GetImageApi *)requests[2];
        GetUserInfoApi *user = (GetUserInfoApi *)requests[3];
        // deal with requests result ...
    } failure:^(YTKBatchRequest *batchRequest) {
        NSLog(@"failed");
    }];
}
```

## YTKChainRequest 类

用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

例如，我们有一个需求，需要用户在注册时，先发送注册的 Api，然后 :
 * 如果注册成功，再发送读取用户信息的 Api。并且，读取用户信息的 Api 需要使用注册成功返回的用户 id 号。
 * 如果注册失败，则不发送读取用户信息的 Api 了。

以下是具体的代码示例，在示例中，我们在 `sendChainRequest` 方法中设置好了 Api 相互的依赖，然后。
我们就可以通过 `chainRequestFinished` 回调来处理所有网络请求都发送成功的逻辑了。如果有任何其中一个网络请求失败了，则会触发 `chainRequestFailed` 回调。

```objectivec
- (void)sendChainRequest {
    RegisterApi *reg = [[RegisterApi alloc] initWithUsername:@"username" password:@"password"];
    YTKChainRequest *chainReq = [[YTKChainRequest alloc] init];
    [chainReq addRequest:reg callback:^(YTKChainRequest *chainRequest, YTKBaseRequest *baseRequest) {
        RegisterApi *result = (RegisterApi *)baseRequest;
        NSString *userId = [result userId];
        GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
        [chainRequest addRequest:api callback:nil];
        
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
```

## 显示上次缓存的内容

在实际开发中，有一些内容可能会加载很慢，我们想先显示上次的内容，等加载成功后，再用最新的内容替换上次的内容。也有时候，由于网络处于断开状态，为了更加友好，我们想显示上次缓存中的内容。这个时候，可以使用 YTKReqeust 的直接加载缓存的高级用法。

具体的方法是直接使用 `YTKRequest` 的 `- (BOOL)loadCacheWithError:` 方法，即可获得上次缓存的内容。当然，你需要把 `- (NSInteger)cacheTimeInSeconds` 覆盖，返回一个大于等于 0 的值，这样才能开启 YTKRequest 的缓存功能，否则默认情况下，缓存功能是关闭的。

以下是一个示例，我们在加载用户信息前，先取得上次加载的内容，然后再发送请求，请求成功后再更新界面：

```objectivec
- (void)loadCacheData {
    NSString *userId = @"1";
    GetUserInfoApi *api = [[GetUserInfoApi alloc] initWithUserId:userId];
    if ([api loadCacheWithError:nil]) {
        NSDictionary *json = [api responseJSONObject];
        NSLog(@"json = %@", json);
        // show cached data
    }
    [api startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSLog(@"update ui");
    } failure:^(YTKBaseRequest *request) {
        NSLog(@"failed");
    }];
}

```

## 上传文件

我们可以通过覆盖 `constructingBodyBlock` 方法，来方便地上传图片等附件，如下是一个示例：

```objectivec
// YTKRequest.h
#import "YTKRequest.h"

@interface UploadImageApi : YTKRequest

- (id)initWithImage:(UIImage *)image;
- (NSString *)responseImageId;

@end

// YTKRequest.m
@implementation UploadImageApi {
    UIImage *_image;
}

- (id)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (NSString *)requestUrl {
    return @"/iphone/image/upload";
}

- (AFConstructingBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

- (id)jsonValidator {
    return @{ @"imageId": [NSString class] };
}

- (NSString *)responseImageId {
    NSDictionary *dict = self.responseJSONObject;
    return dict[@"imageId"];
}

@end
```

通过如上代码，我们创建了一个上传图片，然后获得服务器返回的 imageId 的网络请求 Api。

## 定制网络请求的 HeaderField

通过覆盖 `requestHeaderFieldValueDictionary` 方法返回一个 dictionary 对象来自定义请求的 HeaderField，返回的 dictionary，其 key 即为 HeaderField 的 key，value 为 HeaderField 的 Value，需要注意的是 key 和 value 都必须为 string 对象。

## 定制 `buildCustomUrlRequest`

通过覆盖 `buildCustomUrlRequest` 方法，返回一个 `NSURLRequest` 对象来达到完全自定义请求的需求。该方法定义在 `YTKBaseRequest` 类，如下：

```objectivec
// 构建自定义的 UrlRequest，
// 若这个方法返回非 nil 对象，会忽略 requestUrl, requestArgument, requestMethod, requestSerializerType,requestHeaderFieldValueDictionary
- (NSURLRequest *)buildCustomUrlRequest;
```

如注释所言，如果构建自定义的 request，会忽略其他的一切自定义 request 的方法，例如 `requestUrl`, `requestArgument`, `requestMethod`, `requestSerializerType`,`requestHeaderFieldValueDictionary` 等等。一个上传 gzippingData 的示例如下：

```objectivec
- (NSURLRequest *)buildCustomUrlRequest {
    NSData *rawData = [[_events jsonString] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *gzippingData = [NSData gtm_dataByGzippingData:rawData];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.requestUrl]];
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setHTTPBody:gzippingData];
    return request;
}
```



