YTKNetwork
==========

## YTKRequest是什么

YTKRequest是猿题库基于[AFNetworking](https://github.com/AFNetworking/AFNetworking)封装的一套High Level的API，用于提供更高层次的网络访问抽象。它现在同时被使用在猿题库公司的所有产品的iOS端，包括：[猿题库](http://www.yuantiku.com/)、[小猿搜题](http://www.yuansouti.com/) 、[粉笔直播课](http://ke.fenbi.com/) 。

## YTKRequest提供了哪些功能

相比AFNetworking，YTKRequest提供了以下更高级的功能：

 * 支持按时间缓存网络请求内容
 * 支持按版本号缓存网络请求内容
 * 支持统一设置服务器和CDN的地址
 * 支持检查返回JSON内容的合法性
 * 支持文件的断点续传
 * 支持`block`和`delegate`两种模式的回调方式
 * 支持批量的网络请求发送，并统一设置它们的回调（实现在`YTKBatchRequest`类中）
 * 支持方便地设置有相互依赖的网络请求的发送，例如：发送请求A，根据请求A的结果，选择性的发送请求B和C，再根据B和C的结果，选择性的发送请求D。（实现在`YTKChainRequest`类中）
 * 支持网络请求URL的filter，可以统一为网络请求加上一些参数，或者修改一些路径。
 * 定义了一套插件接口，可以很方便地为YTKRequest增加功能。猿题库官方现在提供了一个插件，可以在某些网络请求发起时，在界面上显示”正在加载“的HUD。

## 哪些项目适合使用YTKRequest

YTKRequest适合稍微复杂一些的项目，不适合个人的小项目。

如果你的项目中需要缓存网络请求、管理多个网络请求之间的依赖、希望检查服务器返回的JSON是否合法，那么YTKRequest能给你带来很大的帮助。如果你缓存的网络请求内容需要依赖特定版本号过期，那么YTKRequest就能发挥出它最大的优势。

## YTKRequest相关的使用教程

我们会尽快提供。

## YTKRequest的作者

YTKRequest的主要作者是：[tangqiaoboy](https://github.com/tangqiaoboy)、[lancy](https://github.com/lancy)、[maojj](https://github.com/maojj)

## 开源协议

YTKRequest采用MIT开源协议
