//
//  MNViewController.m
//  Mana Framework
//
//  Created by Toan Le on 20/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNViewController.h"
#import "TKFunctionGPS.h"
static NSString *main_url = @"https://dl.dropbox.com/u/70353767/WebFramework/ajax.html";
@interface MNViewController ()
{
    //    UIWebView *web_view;
    UIButton *button;
}

@end

@implementation MNViewController
@synthesize web_view;
@synthesize javascriptBridge = _bridge;

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    TKFunctionGPS *fun = [[TKFunctionGPS alloc]init];
    [fun getGPS];
    web_view = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 500)];
    web_view.delegate = self;
    web_view.scalesPageToFit = YES;
    web_view.autoresizesSubviews = YES;
    web_view.autoresizingMask = (UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth);
    web_view.scrollView.bounces = NO;
    web_view.scrollView.decelerationRate = 3.00;
    [self.view addSubview:web_view];
    NSURL* requestUrl = [[NSURL alloc] initWithString:main_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    [requestUrl release];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if([data length] > 0 && error == nil)
        {
            [web_view loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:main_url]];
        }
    }];
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(reloadWeb:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Refresh" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 420, 120, 40);
    [self.view addSubview:button];
     */
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:webView];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        responseCallback(@"Response for message from ObjC");
    }];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    [_bridge send:@"A string sent from ObjC before Webview has loaded." responseCallback:^(id responseData) {
        NSLog(@"objc got response! %@", responseData);
    }];
    
    [_bridge callHandler:@"testJavascriptHandler" data:[NSDictionary dictionaryWithObject:@"before ready" forKey:@"foo"]];
    
    [self renderButtons:webView];
    
    [self loadExamplePage:webView];
    
    [_bridge send:@"A string sent from ObjC after Webview has loaded."];
}

- (void)renderButtons:(UIWebView*)webView
{
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.view insertSubview:messageButton aboveSubview:webView];
	messageButton.frame = CGRectMake(20, 414, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
	callbackButton.frame = CGRectMake(170, 414, 130, 45);
}

- (void)sendMessage:(id)sender
{
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response)
    {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)callHandler:(id)sender
{
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"Hi there, JS!" forKey:@"greetingFromObjC"];
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response)
    {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:appHtml baseURL:nil];
}

- (void) reloadWeb:(id)sender
{
    NSURL* requestUrl = [[NSURL alloc] initWithString:main_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
    [requestUrl release];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if([data length] > 0 && error == nil)
        {
            [web_view loadData:data MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:main_url]];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

