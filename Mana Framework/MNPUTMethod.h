//
//  MNPUTMethod.h
//  Mana Framework
//
//  Created by Toan Le on 15/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "WebViewJavascriptBridge.h"

@interface MNPUTMethod : NSObject

-(id)initWithWebViewJavascriptBridge:(WebViewJavascriptBridge*)_bridge;
-(NSString*)requestPutMethodWithJSON:(NSMutableDictionary*)dic;

@property(nonatomic,retain)WebViewJavascriptBridge *bridge;
@property(nonatomic,retain)NSString *requestStarted;
@property(nonatomic,retain)NSString *requestError;
@property(nonatomic,retain)NSString *requestFinish;


@end
