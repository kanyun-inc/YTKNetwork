YTKNetwork
==========

![License MIT](https://img.shields.io/github/license/mashape/apistatus.svg?maxAge=2592000)
![Pod version](https://img.shields.io/cocoapods/v/YTKNetwork.svg?style=flat)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform info](https://img.shields.io/cocoapods/p/YTKNetwork.svg?style=flat)](http://cocoadocs.org/docsets/YTKNetwork)
[![Build Status](https://api.travis-ci.org/yuantiku/YTKNetwork.svg?branch=master)](https://travis-ci.org/yuantiku/YTKNetwork)

## What

YTKNetwork is a high level request util based on [AFNetworking][AFNetworking]. It's developed by the iOS Team of YuanTiKu. It provides a High Level API for network request.

YTKNetwork is used in all products of YuanTiKu, including: [YuanTiKu][YuanTiKu], [YuanSoTi][YuanSoTi], [YuanFuDao][YuanFuDao], [FenBiZhiBoKe][FenBiZhiBoKe].

[**中文说明**](Docs/README_cn.md)

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

## Why 

YTKNetwork provides YTKRequest to handle every network request. You should inherit it and override some methods to define custom requests in your project.

The main idea is use the Command Pattern. The benefits are:

 * Your code is decoupled to detail network request framework, it's easy to replace it. Actually, YTKNetwork is originally based on ASIHttpRequest, we just spent two days to switch to AFNetworking.
 * Handle common logic in base class.
 * Easier Persistence

But YTKNetwork is not suitable if your project is very simple. You can use AFNetworking directly in controller.

## Installation

To use YTKNetwork add the following to your Podfile

    pod 'YTKNetwork'

Or add this in your Cartfile:

    github "yuantiku/YTKNetwork" ~> 2.0

## Requirements

| YTKNetwork Version | AFNetworking Version |  Minimum iOS Target | Note |
|:------------------:|:--------------------:|:-------------------:|:-----|
| 2.x | 3.x | iOS 7 | Xcode 7+ is required. |
| 1.x | 2.x | iOS 6 | n/a |

YTKNetwork is based on AFNetworking. You can find more detail about version compability at [AFNetworking README](https://github.com/AFNetworking/AFNetworking).

## Guide & Demo

 * [Basic Usage Guide](Docs/BasicGuide_en.md)
 * [YTKNetwork 2.0 Migration Guide(Simplified Chinese)](Docs/2.0_MigrationGuide_cn.md)

## Contributors

 * [lancy][lancyGithub]
 * [maojj][maojjGithub]
 * [veecci][veecciGithub]
 * [tangqiaoboy][tangqiaoboyGithub]
 * [skyline75489][skyline75489Github]

## Acknowledgements

 * [AFNetworking]
 * [AFDownloadRequestOperation]

Thanks for their great work.
 
## License

YTKNetwork is available under the MIT license. See the LICENSE file for more info.

<!-- external links -->

[AFNetworking]:https://github.com/AFNetworking/AFNetworking
[AFDownloadRequestOperation]:https://github.com/steipete/AFDownloadRequestOperation

[YuanTiKu]:http://www.yuantiku.com
[YuanSoTi]:http://www.yuansouti.com/
[YuanFuDao]:http://www.yuanfudao.com
[FenBiZhiBoKe]:http://ke.fenbi.com/
[tangqiaoboyGithub]:https://github.com/tangqiaoboy
[lancyGithub]:https://github.com/lancy
[maojjGithub]:https://github.com/maojj
[veecciGithub]:https://github.com/veecci
[skyline75489Github]:https://github.com/skyline75489
