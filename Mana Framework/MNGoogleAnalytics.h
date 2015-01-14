//
//  MNGoogleAnalytics.h
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"
@interface MNGoogleAnalytics : NSObject

-(NSString*)googleAnalyticsInitializingWithTrackUncaughtExceptions:(BOOL)_exception andDispatchInterval:(NSTimeInterval)_timeDispatch andDebug:(BOOL)_debug andTrackingID:(NSString*)_id;

@end
