YTKNetwork 使用高级教程
===

本教程将讲解 YTKNetwork 的高级功能的使用。

## YTKUrlFilterProtocol 接口

YTKUrlFilterProtocol 接口用于实现对网络请求URL或参数的重写，例如可以统一为网络请求加上一些参数，或者修改一些路径。 

例如：在猿题库中，我们需要为每个网络请求加上客户端的版本号作为参数。所以我们实现了如下一个 `YTKUrlArgumentsFilter` 类，实现了 `YTKUrlFilterProtocol` 接口:

```
// YTKUrlArgumentsFilter.h
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
    return [YTKNetworkPrivate urlStringWithOriginUrlString:originUrl appendParameters:_arguments];
}

@end


```

通过以上`YTKUrlArgumentsFilter` 类，我们就可以用以下代码方便地为网络请求增加统一的参数，如增加当前客户端的版本号：

```

- (BOOL)application:(UIApplication *)application 
         didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupRequestFilters];
    return YES;
}

- (void)setupRequestFilters {
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    YTKNetworkConfig *config = [YTKNetworkConfig sharedInstance];
    YTKUrlArgumentsFilter *urlFilter = [YTKUrlArgumentsFilter filterWithArguments:@{@"version": appVersion}];
    [config addUrlFilter:urlFilter];
}


```

## YTKBatchRequest 类

YTKBatchRequest 类：用于方便地发送批量的网络请求，YTKBatchRequest是一个容器器，它可以放置多个 `YTKRequest` 子类，并统一处理这多个网络请求的成功和失败。

TODO：详细的示例

## YTKChainRequest 类

用于管理有相互依赖的网络请求，它实际上最终可以用来管理多个拓扑排序后的网络请求。

TODO：详细的示例
