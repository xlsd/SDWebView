//
//  SDWebView.h
//  YTXEducation
//
//  Created by 薛林 on 17/2/25.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import <WebKit/WebKit.h>

@protocol SDWebViewDelegate <NSObject>

@optional

/**
 获取从H5页面传递过来的参数

 @param userContentController
 @param message 参数列表
 */
- (void)getParameterFromJS:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

/**
 页面一开始加载就调用

 @param webView 
 @param navigation
 */
- (void)webView:(WKWebView *)webView didLoadFinish:(WKNavigation *)navigation;


/**
 页面开始加载就调用

 @param webView
 @param navigation
 */
- (void)webView:(WKWebView *)webView didStartLoadNavigation:(WKNavigation *)navigation;
@end


@interface SDWebView : WKWebView

/**
 需要加载的urlStr
 */
@property (nonatomic, copy) NSString *URLString;

/**
 进度条
 */
@property (strong, nonatomic) UIProgressView *progressView;

/**
 webView的标题、如果navigationItemTitle需要和webView保持一致、直接getter方法即可
 */
@property (nonatomic, copy) NSString *webViewtitle;

/**
 注入H5页面的交互模型
 */
@property (nonatomic, strong) NSArray<NSString *> *jsHandlers;


/**
 是否显示加载的HTML页面源码 default NO
 */
@property (nonatomic, assign) BOOL displayHTML;

/**
 是否显示加载的HTML页面中的cookie default NO
 */
@property (nonatomic, assign) BOOL displayCookies;

/**
 每次跳转是否需要打印跳转的URL default YES
 */
@property (nonatomic, assign) BOOL displayURL;

/**
 获取交互的参数代理
 */
@property (nonatomic, weak) id<SDWebViewDelegate> delegate;

/**
 根据URL初始化
 @param urlString URLString
 @return WebviewVc实例
 */
- (instancetype)initWithURLString:(NSString *)urlString;

/**
 *  加载本地HTML页面
 *
 *  @param htmlName html页面文件名称
 */
- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName;

/**
 移除jsHandler
 */
- (void)removejsHandlers;

/**
 清除所有cookie
 */
- (void)removeCookies;

/**
 清除指定域名中的cookie
 
 @param cookieName 域名
 */
- (void)removeCookieWithHostName:(NSString *)hostName;

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsMethod JS方法名称
 */
- (void)callJS:(nonnull NSString *)jsMethodName;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsMethod JS方法名称
 *  @param handler  回调block
 */
- (void)callJS:(nonnull NSString *)jsMethodName handler:(nullable void(^)(__nullable id response))handler;

@end
