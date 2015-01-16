//
//  MNRightViewController.h
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNLeftViewController.h"
#import "MNGetFocusScreen.h"

@interface MNRightViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic,retain) UIWebView *webview;
@property (nonatomic,retain) NSString *urlString;

@end
