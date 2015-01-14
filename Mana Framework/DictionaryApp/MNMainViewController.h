//
//  MNMainViewController.h
//  Mana Dictionary
//
//  Created by Tam Tran on 3/20/13.
//  Copyright (c) 2013 Tam Tran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"
@interface MNMainViewController : UIViewController<UIWebViewDelegate>

@property(strong, nonatomic) WebViewJavascriptBridge *webbridge;
@end
