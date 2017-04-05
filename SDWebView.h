//
//  SDWebView.h
//  YTXEducation
//
//  Created by 薛林 on 17/2/25.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface SDWebView : WKWebView<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

/**
 需要加载的urlStr
 */
@property (nonatomic, copy) NSString *URLString;

/**
 web页面中的图片链接数组
 */
@property (nonatomic, strong) NSMutableArray *imgSrcArray;
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
@property (nonatomic, assign) id<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler> webDelegate;

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
//- (void)removeCookieWithHostName:(NSString *)hostName;

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsMethod JS方法名称
 */
- (void)callJavaScript:(nonnull NSString *)jsMethodName;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsMethod JS方法名称
 *  @param handler  回调block
 */
- (void)callJavaScript:(nonnull NSString *)jsMethodName handler:(nullable void(^)(__nullable id response))handler;

@end
