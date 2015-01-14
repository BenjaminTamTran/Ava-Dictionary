//
//  MNPageView.m
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import "MNPageView.h"

@implementation MNPageView

@synthesize textLabel = _textLabel;
@synthesize imageBG,imageTest;
@synthesize webView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
//    NSLog(@"MNPageView initWithReuseIdentifier %@", reuseIdentifier);
	if ((self = [super initWithReuseIdentifier:reuseIdentifier]))
    {
        CGRect webFrame = [[UIScreen mainScreen] applicationFrame];
        webFrame.size.height -= 40;
        webFrame.origin.y -= 20.0;
        self.webView = [[UIWebView alloc] initWithFrame:webFrame];
        self.webView.scalesPageToFit = YES;
        self.webView.autoresizesSubviews = YES;
        self.webView.scrollView.bounces = NO;
        [self addSubview:self.webView];
	}
	return self;
}

- (void)dealloc {
    [imageBG release];
    [webView release];
    [imageTest release];
    [super dealloc];
}
@end
