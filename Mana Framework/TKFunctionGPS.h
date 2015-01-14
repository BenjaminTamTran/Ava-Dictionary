//
//  TKFunction.h
//  TestNativeControl
//
//  Created by Toan Le on 06/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreLocation/CoreLocation.h>
#import "MNConnection.h"

@interface TKFunctionGPS : UIViewController <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property(assign,nonatomic) float longitude;
@property(assign,nonatomic) float latitude;
@property (retain, nonatomic) CLLocationManager *locationManager;

-(void)getGPS;

@end
