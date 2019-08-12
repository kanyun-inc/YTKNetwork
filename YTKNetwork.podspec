Pod::Spec.new do |s|

  s.name         = "YTKNetwork"
  s.version      = "2.1.0"
  s.summary      = "YTKNetwork is a high level request util based on AFNetworking."
  s.homepage     = "https://github.com/yuantiku/YTKNetwork"
  s.license      = "MIT"
  s.author       = {
                    "tangqiao" => "tangqiao@fenbi.com",
                    "lancy" => "lancy@fenbi.com",
                    "maojj" => "maojj@fenbi.com",
                    "liujl" => "liujl@fenbi.com"
 }
  s.source        = { :git => "ssh://gerrit.zhenguanyu.com:29418/YTKNetwork", :tag => s.version.to_s }
  s.requires_arc  = true
  s.source_files  = "YTKNetwork/YTKNetwork.h"
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.framework = "CFNetwork"

  s.dependency "AFNetworking", "~> 3.0"

  s.default_subspecs = "Core"

  s.subspec "Core" do |ss|
    ss.source_files = "YTKNetwork/Core/**/*.{h,m,mm}"
    ss.private_header_files = "YTKNetwork/Core/YTKNetworkPrivate.h"
    ss.requires_arc = true
  end

  s.subspec "Additional" do |ss|
    ss.source_files = "YTKNetwork/Additional/**/*.{h,m,mm}"
    ss.requires_arc = true
    ss.platform = :ios, '7.0'
    ss.dependency "YTKNetwork/Core"
    ss.dependency "MBProgressHUD", "~> 0.9.2"
  end

end
