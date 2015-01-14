//
//  MNPOSTMethod.h
//  Mana Framework
//
//  Created by Toan Le on 13/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebViewJavascriptBridge.h"

@interface MNPOSTMethod : NSObject

@property(nonatomic,retain)WebViewJavascriptBridge *bridge;
@property(nonatomic,retain)NSString *requestStarted;
@property(nonatomic,retain)NSString *requestError;
@property(nonatomic,retain)NSString *requestFinish;

-(id)initWithWebViewJavascriptBridge:(WebViewJavascriptBridge*)_bridge;
-(NSString*)requestPostMethodWithJSON:(NSMutableDictionary*)dic;

@end
