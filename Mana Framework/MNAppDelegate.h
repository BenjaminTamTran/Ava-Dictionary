//
//  MNAppDelegate.h
//  Mana Framework
//
//  Created by Toan Le on 20/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
#import "HTTPResponse.h"
#import "MyHTTPConnection.h"
#import "GCDAsyncSocket.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "TKFunctionGPS.h"
@class MNViewController;

@interface MNAppDelegate : UIResponder <UIApplicationDelegate>
{
    HTTPServer *httpServer;
	NSDictionary *addresses;
    AVAudioPlayer *audioPlayer;
    UIView *toast;
    int audio_state;
    BOOL register_media_state;
    NSString *json_media_state;
    BOOL run_java_script;
    NSString *javascript_to_run;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) int audio_state;
@property (nonatomic) BOOL register_media_state;
@property (nonatomic) BOOL run_java_script;
@property(nonatomic,retain) AVAudioPlayer *audioPlayer;
@property(nonatomic,retain) NSString *json_media_state;
@property(nonatomic,retain) NSString *javascript_to_run;
@property (strong, nonatomic) MNViewController *viewController;
@property(nonatomic,retain) UIView *toast;

@end
