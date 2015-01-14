//
//  MNMainViewController.m
//  Mana Dictionary
//
//  Created by Tam Tran on 3/20/13.
//  Copyright (c) 2013 Tam Tran. All rights reserved.
//

#import "MNMainViewController.h"
#import "MNGETMethod.h"
#import "MNDatabaseManagement.h"

@interface MNMainViewController ()

@end

@implementation MNMainViewController
@synthesize  webbridge = _webbridge;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    webView.delegate = self;
    webView.scrollView.bounces = NO;
    [self.view addSubview:webView];
    [WebViewJavascriptBridge enableLogging];
    
    _webbridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        //TU DIEN TRY: download file first time
        NSMutableDictionary *dicJson;
        dicJson = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        //TU DIEN TRY: check database
        MNDatabaseManagement *database = [[MNDatabaseManagement alloc] init];
        NSString *json_data = [database executeSQL2:dicJson];
        responseCallback(json_data);
    }];
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"Dictionary" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:appHtml baseURL:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
