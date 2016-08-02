Pod::Spec.new do |s|

  s.name         = "YTKNetwork"
  s.version      = "1.2.0"
  s.summary      = "YTKNetwork is a high level request util based on AFNetworking."
  s.homepage     = "https://github.com/yuantiku/YTKNetwork"
  s.license      = "MIT"
  s.author             = {
                          "tangqiao" => "tangqiao@fenbi.com",
                          "lancy" => "lancy@fenbi.com",
                          "maojj" => "maojj@fenbi.com"
 }
  s.source        = { :git => "https://github.com/yuantiku/YTKNetwork.git", :tag => s.version.to_s }
  s.source_files  = "YTKNetwork/*.{h,m}"
  s.private_header_files = "YTKNetwork/YTKNetworkPrivate.h"
  s.platform      = :ios, '7.0'
  s.requires_arc  = true
  s.dependency "AFNetworking", "~> 3.0"
end
