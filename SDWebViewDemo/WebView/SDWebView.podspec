#
#  Be sure to run `pod spec lint SDWebView.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "SDWebView"
  s.version      = "1.0.0"
  s.summary      = "Base on WKWebView"
  s.description  = "Base on WKWebView, handler WKWebView and javaScript"
  s.homepage     = "https://github.com/giveMeHug/SDWebView"
  s.license      = "MIT"
  s.author             = { "as_one" => "413890968@qq.com" }
  s.platform     = :ios
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/giveMeHug/SDWebView.git", :tag => s.version }
  s.source_files  = "SDWebViewDemo/WebView.{h,m}"

end
