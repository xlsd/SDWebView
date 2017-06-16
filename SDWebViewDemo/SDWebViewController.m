//
//  SDWebViewController.m
//  SDWebViewDemo
//
//  Created by 薛林 on 17/4/5.
//  Copyright © 2017年 YunTianXia. All rights reserved.
//

#import "SDWebViewController.h"
#import "SDWebView.h"

@interface SDWebViewController ()

@end

@implementation SDWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    SDWebView *webView = [[SDWebView alloc] initWithFrame:self.view.bounds];
    [webView loadLocalHTMLWithFileName:@"source"];
    
    
    //  Example like this, you need set ATS allow load Yes.
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    
    [self.view addSubview:webView];
    
}


@end
