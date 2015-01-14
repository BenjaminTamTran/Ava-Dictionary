//
//  MNConnection.h
//  Mana portal
//
//  Created by Toan Le on 12/6/12.
//  Copyright (c) 2012 Mana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

@interface MNConnection: NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}


+ (MNConnection*) reachabilityWithHostName: (NSString*) hostName;


+ (MNConnection*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;


+ (MNConnection*) reachabilityForInternetConnection;


+ (MNConnection*) reachabilityForLocalWiFi;


- (BOOL) startNotifier;
- (void) stopNotifier;

- (NetworkStatus) currentReachabilityStatus;

- (BOOL) connectionRequired;
@end

