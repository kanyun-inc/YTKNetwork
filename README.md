YTKNetwork 
==========

![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
![Pod version](http://img.shields.io/cocoapods/v/YTKNetwork.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/YTKNetwork.svg?style=flat)
[![Build Status](https://api.travis-ci.org/yuantiku/YTKNetwork.svg?branch=master)](https://travis-ci.org/yuantiku/YTKNetwork)

## What

YTKNetwork is is a high level request util based on [AFNetworking][AFNetworking]. It's developed by the iOS Team of YuanTiKu. It provides a High Level API for network request.

YTKNetwork is used in all products of YuanTiKu, including: [YuanTiKu][YuanTiKu], [YuanSoTi][YuanSoTi], [YuanFuDao][YuanFuDao], [FenBiZhiBoKe][FenBiZhiBoKe].

## Features

* Response can be cached by expiration time
* Response can be cached by version number
* Set common base URL and CDN URL
* Validate JSON response
* Resume download
* `block` and `delegate` callback
* Batch requests (see `YTKBatchRequest`)
* Chain requests (see `YTKChainRequest`)
* URL filter, replace part of URL, or append common parameter 
* Plugin mechanism, handle request start and finish. A plugin for show "Loading" HUD is provided

## Who

YTKNetowrk is suitable for a slightly more complex project, not for a simple personal project.

YTKNetwork is helpful if you want to cache requests, manage the dependences of requests, or validate the JSON response. And if you want to cache requests based on request version, this is one of the greatest advantages of YTKNetwork.

iOS 6+ is required.

## Why 

YTKNetwork provides YTKRequest to handle every network request. You should inherit it and override some methods to define custom requests in your project.

The main idea is use the Command Pattern. The benefits are:

 * Your code is decoupled to detail network request framework, it's easy to replace it. Actually, YTKNetwork is originally based on ASIHttpRequest, we just spent two days to switch to AFNetworking.
 * Handle common logic in base class.
 * Easier Persistence

But YTKNetwork is not suitable if your project is very simple. You can use AFNetworking directly in controller.

## CocoaPods
To use YTKNetwork add the following to your Podfile

    pod 'YTKNetwork'

## Guide & Demo

 * [Basic Usage Guide][BasicGuide-EN]

## Contributors

 * [tangqiaoboy][tangqiaoboyGithub]
 * [lancy][lancyGithub]
 * [maojj][maojjGithub]
 * [veecci][veecciGithub]

## Acknowledgements

 * [AFNetworking]
 * [AFDownloadRequestOperation]

Thanks for their great work.
 
## License

YTKNetwork is available under the MIT license. See the LICENSE file for more info.

---
README(Chinese)
==========

## YTKNetwork 是什么

YTKNetwork 是猿题库 iOS 研发团队基于 [AFNetworking][AFNetworking] 封装的 iOS 网络库，其实现了一套 High Level 的 API，提供了更高层次的网络访问抽象。YTKNetwork 现在同时被使用在猿题库公司的所有产品的 iOS 端，包括：[猿题库][YuanTiKu]、 [小猿搜题][YuanSoTi]、 [猿辅导][YuanFuDao] 、 [粉笔直播课][FenBiZhiBoKe] 。

## YTKNetwork提供了哪些功能

相比 AFNetworking，YTKNetwork 提供了以下更高级的功能：

 * 支持按时间缓存网络请求内容
 * 支持按版本号缓存网络请求内容
 * 支持统一设置服务器和 CDN 的地址
 * 支持检查返回 JSON 内容的合法性
 * 支持文件的断点续传
 * 支持 `block` 和 `delegate` 两种模式的回调方式
 * 支持批量的网络请求发送，并统一设置它们的回调（实现在`YTKBatchRequest`类中）
 * 支持方便地设置有相互依赖的网络请求的发送，例如：发送请求A，根据请求A的结果，选择性的发送请求B和C，再根据B和C的结果，选择性的发送请求D。（实现在`YTKChainRequest`类中）
 * 支持网络请求 URL 的 filter，可以统一为网络请求加上一些参数，或者修改一些路径。
 * 定义了一套插件机制，可以很方便地为 YTKNetwork 增加功能。猿题库官方现在提供了一个插件，可以在某些网络请求发起时，在界面上显示"正在加载"的 HUD。

## 哪些项目适合使用 YTKNetwork

YTKNetwork 适合稍微复杂一些的项目，不适合个人的小项目。

如果你的项目中需要缓存网络请求、管理多个网络请求之间的依赖、希望检查服务器返回的 JSON 是否合法，那么 YTKNetwork 能给你带来很大的帮助。如果你缓存的网络请求内容需要依赖特定版本号过期，那么 YTKNetwork 就能发挥出它最大的优势。

YTKNetwork 支持iOS 6或之后的版本。

## YTKNetwork 的基本思想

YTKNetwork 的基本的思想是把每一个网络请求封装成对象。所以使用 YTKNetwork，你的每一个请求都需要继承`YTKRequest`类，通过覆盖父类的一些方法来构造指定的网络请求。

把每一个网络请求封装成对象其实是使用了设计模式中的 Command 模式，它有以下好处：

 * 将网络请求与具体的第三方库依赖隔离，方便以后更换底层的网络库。实际上 YTKNetwork 最初是基于 ASIHttpRequest 的，我们只花了两天，就很轻松地切换到了 AFNetworking。
 * 方便在基类中处理公共逻辑，例如猿题库的数据版本号信息就统一在基类中处理。
 * 方便在基类中处理缓存逻辑，以及其它一些公共逻辑。
 * 方便做对象的持久化。

当然，如果说它有什么不好，那就是如果你的工程非常简单，这么写会显得没有直接用 AFNetworking 将请求逻辑写在 Controller 中方便，所以 YTKNetwork 并不合适特别简单的项目。

## CocoaPods 支持

你可以在 Podfile 中加入下面一行代码来使用YTKNetwork

    pod 'YTKNetwork'

## 相关的使用教程和 Demo

 * [基础使用教程][BasicGuide-CN]
 * [高级使用教程][ProGuide-CN]

## 作者

YTKNetwork 的主要作者是：

* [tangqiaoboy][tangqiaoboyGithub]
* [lancy][lancyGithub]
* [maojj][maojjGithub]
* [veecci][veecciGithub]

## 感谢

YTKNetwork 基于 [AFNetworking][AFNetworking] 和 [AFDownloadRequestOperation][AFDownloadRequestOperation] 进行开发，感谢他们对开源社区做出的贡献。

## 协议

YTKNetwork 被许可在 MIT 协议下使用。查阅 LICENSE 文件来获得更多信息。


<!-- external links -->

[BasicGuide-CN]: BasicGuide.md
[ProGuide-CN]: ProGuide.md
[BasicGuide-EN]: BasicGuide_en.md
[YuanTiKu]:http://www.yuantiku.com
[YuanSoTi]:http://www.yuansouti.com/
[YuanFuDao]:http://www.yuanfudao.com
[FenBiZhiBoKe]:http://ke.fenbi.com/
[tangqiaoboyGithub]:https://github.com/tangqiaoboy
[lancyGithub]:https://github.com/lancy
[maojjGithub]:https://github.com/maojj
[veecciGithub]:https://github.com/veecci
[AFNetworking]:https://github.com/AFNetworking/AFNetworking
[AFDownloadRequestOperation]:https://github.com/steipete/AFDownloadRequestOperation
