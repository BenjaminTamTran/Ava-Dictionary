//
//  MNRightViewController.m
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import "MNRightViewController.h"
#import "JASidePanelController.h"

#import "UIViewController+JASidePanel.h"

@interface MNRightViewController ()

@end

@implementation MNRightViewController
@synthesize webview,urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Extend";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.urlString = @"http://www.google.com";
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(30, 0, self.view.bounds.size.width, 480)];
    self.webview.delegate = self;
    self.webview.scrollView.bounces = NO;
    [self.view addSubview:self.webview];
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"Dictionary-Right" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:appHtml baseURL:nil];
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
//    [self.webview loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    MNGetFocusScreen *controller = [[MNGetFocusScreen alloc]init];
    [controller stateScreenWithScreenNumber:@"6"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *javascriptString = [[NSString alloc] initWithFormat:@"document.body.style.width = '280px'"];
    [webview stringByEvaluatingJavaScriptFromString:javascriptString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
