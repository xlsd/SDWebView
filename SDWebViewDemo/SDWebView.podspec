
Pod::Spec.new do |s|

s.name         = "SDWebView"
s.version      = "1.0.1"
s.summary      = "Base on WKWebView."
s.description  = "Base on WKWebView, handel javaScript"
s.homepage     = "https://github.com/giveMeHug/SDWebView"
s.license      = { :type => "MIT", :file => "LICENSE" }
s.author             = { "xuelin" => "413890968@qq.com" }
s.source       = { :git => "https://github.com/giveMeHug/SDWebView.git", :tag => s.version }
s.source_files  = "SDWebView/*.{h,m}, SDWebView/PhotoBrowseView/*.{h,m},SDWebView/PhotoBrowseView/Quartz/*.{h,m},SDWebView/PhotoBrowseView/YYWebImage/*.{h,m},SDWebView/PhotoBrowseView/YYWebImage/**/*.{h,m}"
end
