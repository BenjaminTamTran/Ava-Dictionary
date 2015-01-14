//
//  MNGoogleAnalytics.m
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNGoogleAnalytics.h"

@implementation MNGoogleAnalytics

-(NSString*)googleAnalyticsInitializingWithTrackUncaughtExceptions:(BOOL)_exception andDispatchInterval:(NSTimeInterval)_timeDispatch andDebug:(BOOL)_debug andTrackingID:(NSString *)_id
{
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = _timeDispatch;
    [GAI sharedInstance].debug = _debug;
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:_id];
    [GAI sharedInstance].defaultTracker = tracker;
    return [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"OK\"}"];
}

@end
