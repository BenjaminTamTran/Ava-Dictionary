//
//  MNDELETEMethod.h
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/15/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"
@interface MNDELETEMethod : NSObject
-(NSString *)requestDELETEMethodWithJSON:(NSMutableDictionary*)dic;
-(id)initWithWebViewJavascriptBridge:(WebViewJavascriptBridge*)_bridge;
@property(nonatomic,retain)WebViewJavascriptBridge *bridge;
@property(nonatomic,retain)NSString *requestStarted;
@property(nonatomic,retain)NSString *requestError;
@property(nonatomic,retain)NSString *requestFinish;
@end
