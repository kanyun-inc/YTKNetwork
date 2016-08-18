YTKNetwork 2.0 迁移指南
======================

YTKNetwork 2.0 所依赖的 AFNetworking 版本从 2.X 变为 3.X 版本，抛弃了旧有的以 `AFHTTPRequestOperation` 为核心的 API，采用新的基于 `NSURLSession` 的 API。本指南的目的在于帮助使用 YTKNetwork 1.X 版本的应用迁移到新的 API。

## AFHTTPRequestOperation 完全被移除

在 iOS 7 上苹果引入了 `NSURLSession` 系列 API，旨在替代 `NSURLConnection` 系列 API。在 Xcode 7 中，`NSURLConnection` API 已经正式标记为废弃的（deprecated）。AFNetworking 3 当中也放弃了基于 `NSOperation` 的请求方式，转而采用基于 `NSURLSessionTask`。因此 `YTKRequest` 中的下列属性发生了变化：

#### YTKNetwork 1.X

```Objective-C
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
@property (nonatomic, strong, readonly, nullable) NSError *requestOperationError;
```

#### YTKNetwork 2.X

```Objective-C
@property (nonatomic, strong, readonly) NSURLSessionTask *requestTask;
@property (nonatomic, strong, readonly, nullable) NSError *error;
```

同时，原来依赖于 `AFHTTPRequestOperation` 的这些属性，需要使用新加入的替代 API 获取：

* `request.requestOperation.response` --> `request.response`
* `request.requestOperation.request` --> `request.currentRequest` & `request.originalRequest`

由于失去了 Operation 封装类，`request.currentRequest` 和 `request.originalRequest` 属性需要在 request 进行 `start` 之后才能获取，否则为 nil。

## 响应序列化选项

YTKNetwork 2.0 中加入了新的响应序列化选项，以及对应的 `responseObject` 属性，不同的序列化选项会导致响应返回不同类型的 `responseObject`，具体对应如下：

```Objective-C
typedef NS_ENUM(NSInteger, YTKResponseSerializerType) {
    YTKResponseSerializerTypeHTTP = 0,  /// NSData
    YTKResponseSerializerTypeJSON,      /// JSON object
    YTKResponseSerializerTypeXMLParser  /// NSXMLParser
};
```

默认的序列化选项是 `YTKResponseSerializerTypeHTTP`。

## 下载请求

原来基于 `AFDownloadRequestOperation` 的下载请求改为使用系统自己的 `NSURLSessionDownloadTask`。当 `YTKRequest` 的 `resumableDownloadPath` 属性不为 nil 的情况下，会调用 `NSURLSessionDownloadTask` 进行下载，下载完成后文件会自动保存到给出的路径，无需再进行存储操作。

对于下载请求来说，响应属性的获取行为如下：

* `responseData`：可以获取
* `responseString`：不能获取
* `responseObject`：为 NSURL，是下载文件在本地所存储的路径。

如果在使用 YTKNetwork 1.X 的情况下，采用存储 `responseData` 的方式进行下载，那么无需进行改动。不过对于下载完整文件的情况，建议迁移到新的采用 `NSURLSessionDownloadTask` 的 API。

同时，获取下载进度的 API 也发生了变化，旧的 block 类型被抛弃，新的 block 类型取自 AFN 3.X：

```Objective-C
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);
```

可以通过 `NSProgress` 的 `totalUnitCount` 和 `completedUnitCount` 获取下载进度有关的信息。

## YTKNetworkPrivate 不再暴露

`YTKNetworkPrivate.h` 将会成为私有头文件，所以依赖于此头文件的方法将不再可用。

## Cache API 更新

`YTKRequest` 类当中的 Cache 有关接口发生改变，不发送请求的情况下获取 Cache 的下列接口被去除：

* `- (id)cacheJson`
* `- (BOOL)isCacheVersionExpired;`

新的替代接口为：

* `- (BOOL)loadCacheWithError:(NSError **)error`

这个接口可以用于在不发送请求的情况下，直接读取磁盘缓存，返回值表示获取成功与否，如果获取失败，error 会返回错误的具体信息。读取缓存成功后，可以直接通过 `responseObject`，`responseData` 等属性获取数据。

用于将一个请求的响应写到另一个请求的缓存中的接口，也发生了变化：

#### YTKNetwork 1.X

`- (void)saveJsonResponseToCacheFile:(id)jsonResponse`

#### YTKNetwork 2.X

`- (void)saveResponseDataToCacheFile:(NSData *)data`

YTKNetwork 2.0 中加入了用于控制是否进行异步写缓存的接口：

`- (BOOL)writeCacheAsynchronously`

默认返回 `YES`，即使用异步方式写缓存，以提高性能。如果需要关闭此功能，可以在子类中覆盖这个方法并返回 `NO`。

## 响应前向处理

与 `- (void)requestCompleteFilter` 和 `- (void)requestFailedFilter` 对应， YTKNetwork 2.0 中加入了用于在响应结束，但是切换回主线程之前执行操作的函数 `- (void)requestCompletePreprocessor` 和 `- (void)requestFailedPreprocessor`，在这里执行的操作，可以避免卡顿主线程。
