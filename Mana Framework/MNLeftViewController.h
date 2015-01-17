//
//  MNLeftViewController.h
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewJavascriptBridge.h"
#import "MNGPS.h"
#import "MNNotification.h"
#import "MNIconBadgeNumber.h"
#import "MNNotification.h"
#import "MNMD5.h"
#import <MessageUI/MessageUI.h> 
#import "MNSplashScreen.h"
#import "MNSetFocusScreen.h"
#import "MNGetFocusScreen.h"
#import "MNViewDetailViewController.h"
#import "MNPOSTMethod.h"
#import "MNPUTMethod.h"
#import "SSZipArchive.h"
#import "MNReadZIP.h"

@interface MNLeftViewController : UIViewController<UIWebViewDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic, strong, readonly) UIButton *hide;
@property (nonatomic, strong, readonly) UIButton *show;
@property (nonatomic, strong, readonly) UIButton *removeRightPanel;
@property (nonatomic, strong, readonly) UIButton *addRightPanel;
@property (nonatomic, strong, readonly) UIButton *changeCenterPanel;

@property (strong, nonatomic) WebViewJavascriptBridge *javascriptBridge;

- (IBAction)onTapNavigationMain:(id)sender;
- (IBAction)onTapNavigationMainAndFocus:(id)sender;
- (IBAction)onTapNavigationRight:(id)sender;
- (IBAction)onTapNavigationRightAndFocus:(id)sender;

@end
