Pod::Spec.new do |s|

  s.name         = "YTKNetwork"
  s.version      = "0.1.0"
  s.summary      = "YTKNetwork is a high level request util based on AFNetworking."
  s.description  = <<-DESC
 * Response can be cached by expiration time
 * Response can be cached by version number
 * Set common base URL and CDN URL
 * Validate JSON response
 * Resume download
 * block and delegate callback
 * Batch requests (see YTKBatchRequest)
 * Chain requests (see YTKChainRequest)
 * URL filter, replace part of URL, or append common parameter
 * Plugin mechanism
                   DESC
  s.homepage     = "http://github.com/yuantiku/YTKNetwork"
  s.license      = "MIT"
  s.author             = {
                          "tangqiao" => "tangqiao@fenbi.com",
                          "lancy" => "lancy@fenbi.com",
                          "maojj" => "maojj@fenbi.com"
 }
  s.source       = { :git => "http://github.com/yuantiku/YTKNetwork.git", :tag => "0.1.0" }
  s.source_files  = "YTKNetwork/*.{h,m}"
  s.requires_arc = true
  s.dependency "AFNetworking", "~> 2.0"
  s.dependency "AFDownloadRequestOperation", "~> 2.0"

end
