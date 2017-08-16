//
//  SDWebView.h
//  YTXEducation
//
//  Created by 薛林 on 17/2/25.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface SDWebView : WKWebView<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

/**
 需要加载的URLString
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
 注入H5页面的交互模型(可以是多个，也可以是一个)
 */
@property (nonatomic, strong) NSArray<NSString *> *jsHandlers;

/**
 获取交互的参数代理
 */
@property (nonatomic, weak) id<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler> webDelegate;

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
 
 @param hostName 域名
 */
- (void)removeCookieWithHostName:(NSString *)hostName;

/**
 *  调用JS方法（无返回值）
 *
 *  @param jsMethodName JS方法名称
 */
- (void)callJavaScript:(nonnull NSString *)jsMethodName;

/**
 *  调用JS方法（可处理返回值）
 *
 *  @param jsMethodName JS方法名称
 *  @param handler  回调block
 */
- (void)callJavaScript:(nonnull NSString *)jsMethodName handler:(nullable void(^)(__nullable id response))handler;

@end
NS_ASSUME_NONNULL_END
