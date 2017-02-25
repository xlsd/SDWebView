//
//  SDWebView.m
//  YTXEducation
//
//  Created by 薛林 on 17/2/25.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import "SDWebView.h"
#import <Foundation/Foundation.h>

static NSString *MEIQIA = @"meiqia";

@interface SDWebView ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@end


@implementation SDWebView

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    [self setDefaultValue];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setDefaultValue];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKWebViewConfiguration *configer = [[WKWebViewConfiguration alloc] init];
    configer.userContentController = [[WKUserContentController alloc] init];
    configer.preferences = [[WKPreferences alloc] init];
    configer.preferences.javaScriptEnabled = YES;
    configer.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    self = [super initWithFrame:frame configuration:configer];
    [self setDefaultValue];
    return self;
}

- (void)setURLString:(NSString *)URLString {
    _URLString = URLString;
    [self setDefaultValue];
}

- (void)setDefaultValue {
    _displayHTML = NO;
    _displayCookies = NO;
    _displayURL = YES;
    self.UIDelegate = self;
    self.navigationDelegate = self;
    self.scrollView.showsVerticalScrollIndicator = NO;
}

- (void)loadLocalHTMLWithFileName:(nonnull NSString *)htmlName {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:htmlName
                                                          ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath
                                                    encoding:NSUTF8StringEncoding
                                                       error:nil];
    
    [self loadHTMLString:htmlCont baseURL:baseURL];
}

- (void)setJsHandlers:(NSArray<NSString *> *)jsHandlers {
    _jsHandlers = jsHandlers;
    for (NSString *handlerName in jsHandlers) {
        [self.configuration.userContentController addScriptMessageHandler:self name:handlerName];
    }
}

#pragma mark - js调用原生方法 可在此方法中获得传递回来的参数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(getParameterFromJS:didReceiveScriptMessage:)]) {
        [self.delegate getParameterFromJS:userContentController didReceiveScriptMessage:message];
    }
}

#pragma mark - 检查cookie及页面HTML元素
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (_displayCookies) {
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [cookieJar cookies]) {
            NSLog(@"%@", cookie);
        }
    }
    if (_displayHTML) {
        NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
        [webView evaluateJavaScript:jsToGetHTMLSource completionHandler:^(id _Nullable HTMLsource, NSError * _Nullable error) {
            NSLog(@"%@",HTMLsource);
        }];
    }
    if ([self.delegate respondsToSelector:@selector(webView:didLoadFinish:)]) {
        [self.delegate webView:webView didLoadFinish:navigation];
    }
}

#pragma mark - 页面开始加载就调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if ([self.delegate respondsToSelector:@selector(webView:didStartLoadNavigation:)]) {
        [self.delegate webView:webView didStartLoadNavigation:navigation];
    }
}

#pragma mark - 导航每次跳转调用跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (_displayURL) {
        NSString *URLStr = navigationAction.request.URL.absoluteString;
        NSLog(@"-----------%@",URLStr);
        //在客服页面隐藏导航栏
        if ([URLStr rangeOfString:MEIQIA].location != NSNotFound) {
            self.frame = CGRectMake(0, -64, ScreenWidth, ScreenHeight);
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight - 64);});
        }
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

#pragma mark - 移除jsHandler
- (void)removejsHandlers {
    NSAssert(_jsHandlers, @"未找到jsHandler!无需移除");
    if (_jsHandlers) {
        for (NSString *handlerName in _jsHandlers) {
            [self.configuration.userContentController removeScriptMessageHandlerForName:handlerName];
        }
    }
}

#pragma mark - 进度条
- (UIProgressView *)progressView {
    if(!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
        _progressView.tintColor = [UIColor orangeColor];
        _progressView.trackTintColor = [UIColor whiteColor];
        [self addSubview:_progressView];
    }
    return _progressView;
}

#pragma mark - 清除cookie
- (void)removeCookies {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                       forDataRecords:@[record]
                                                                    completionHandler:^{
                                                                        NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                    }];
                         }
                     }];
}

- (void)removeCookieWithHostName:(NSString *)hostName {
    WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
    [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                     completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                         for (WKWebsiteDataRecord *record  in records) {
                             if ( [record.displayName containsString:hostName]) {
                                 [[WKWebsiteDataStore defaultDataStore]removeDataOfTypes:record.dataTypes
                                                                          forDataRecords:@[record] completionHandler:^{
                                                                              NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                          }];
                             }
                         }
                     }];
}

- (void)callJS:(NSString *)jsMethodName {
    [self callJS:jsMethodName handler:nil];
}

- (void)callJS:(NSString *)jsMethodName handler:(void (^)(id _Nullable))handler {
    
    NSLog(@"call js:%@",jsMethodName);
    [self evaluateJavaScript:jsMethodName completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if (handler) {
            handler(response);
        }
    }];
}

@end
