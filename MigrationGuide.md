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


## 下载请求

原来基于 `AFDownloadRequestOperation` 的下载请求改为使用系统自己的 `NSURLSessionDownloadTask`。当 `YTKRequest` 的 `resumableDownloadPath` 属性不为 nil 的情况下，会调用 `NSURLSessionDownloadTask` 进行下载，下载完成后文件会自动保存到给出的路径，无需再进行存储操作。

对于下载请求来说，响应属性的获取行为如下：

* `responseData`：始终不能获取
* `responseString`：始终不能获取
* `responseObject`：为 NSURL，是下载文件在本地所存储的路径。

如果在使用 YTKNetwork 1.X 的情况下，采用存储 `responseData` 的方式进行下载，那么无需进行改动。不过对于下载完整文件的情况，建议迁移到新的采用 `NSURLSessionDownloadTask` 的 API。

同时，获取下载进度的 API 也发生了变化，旧的 block 类型被抛弃，新的 block 类型取自 AFN 3.X：

```Objective-C
typedef void (^AFURLSessionTaskProgressBlock)(NSProgress *);
```

可以通过 `NSProgress` 的 `totalUnitCount` 和 `completedUnitCount` 获取下载进度有关的信息。

