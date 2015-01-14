//
//  MNViewController.h
//  Mana Framework
//
//  Created by Toan Le on 20/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"

@interface MNViewController : UIViewController<UIWebViewDelegate>{
    UIWebView *web_view;
}

@property(nonatomic,retain) UIWebView *web_view;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

- (void)renderButtons:(UIWebView*)webView;
- (void)loadExamplePage:(UIWebView*)webView;

@end
