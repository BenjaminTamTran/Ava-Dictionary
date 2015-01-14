//
//  TKFunction.m
//  TestNativeControl
//
//  Created by Toan Le on 06/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import "TKFunctionGPS.h"

@interface TKFunctionGPS ()

@end

@implementation TKFunctionGPS

@synthesize latitude,longitude;
@synthesize locationManager;

-(void)getGPS
{
    [self setLocationManager:[[[CLLocationManager alloc] init] autorelease]];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"Latitude:%f",newLocation.coordinate.latitude);
    //NSLog(@"Longitude:%f",newLocation.coordinate.longitude);
    self.longitude = newLocation.coordinate.longitude;
    self.latitude = newLocation.coordinate.latitude;
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    [defaults setFloat:self.longitude forKey:@"longitude"];
    [defaults setFloat:self.latitude forKey:@"latitude"];
    
}

@end
