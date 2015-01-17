//
//  MNCenterViewController.h
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JASidePanelController.h"
#import "WebViewJavascriptBridge.h"
#import "UIViewController+JASidePanel.h"
#import "MNGETMethod.h"
#import "MNDatabaseManagement.h"
#import "MNGetFocusScreen.h"
#import <MessageUI/MessageUI.h> 
@class GADBannerView;

@interface MNCenterViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property(strong, nonatomic) WebViewJavascriptBridge *webbridge;
@property (nonatomic,retain) NSString *urlString;
@property (nonatomic,retain) NSString *json_data;
@property (nonatomic,retain) IBOutlet UIView *loadingView;
@property (nonatomic,retain) IBOutlet UIWebView *webView;
@property (nonatomic,retain) IBOutlet UILabel *labelLoading;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *indicatorLoading;
@property (weak, nonatomic) IBOutlet GADBannerView  *bannerView;
@property (nonatomic)int menu_;
@property (nonatomic,retain) NSString *Source_viet_anh;
@property (nonatomic,retain) NSString *Source_anh_viet;
@property(strong,nonatomic) NSString *appNameToAdvertising;
@end
