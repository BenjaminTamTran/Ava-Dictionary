//
//  MNPageView.h
//  TestSwipeWebView
//
//  Created by Toan Le on 27/12/2012.
//  Copyright (c) 2012 Toan Le. All rights reserved.
//

#import "TKPageView.h"

@interface MNPageView : TKPageView

@property (retain, nonatomic) IBOutlet UIImageView *imageBG;
@property (nonatomic, strong, readonly) UILabel *textLabel;
@property (nonatomic, strong, readonly) UIImageView *imageTest;
@property (nonatomic, strong) UIWebView *webView;
@end
