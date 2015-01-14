//
//  MNGETMethod.h
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/15/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"
@interface MNGETMethod : NSObject
-(id)initWithWebViewJavascriptBridge:(WebViewJavascriptBridge*)_bridge;
-(NSString *)requestGETMethodWithJSON:(NSMutableDictionary*)dic;
-(NSString *)requestWithString;
@property(nonatomic,retain)WebViewJavascriptBridge *bridge;
@property(nonatomic,retain)NSString *requestStarted;
@property(nonatomic,retain)NSString *requestError;
@property(nonatomic,retain)NSString *requestFinish;
@end
