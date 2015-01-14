//
//  SSAccelerometerInfo.h
//  SystemServicesDemo
//
//  Created by Shmoopi LLC on 9/20/12.
//  Copyright (c) 2012 Shmoopi LLC. All rights reserved.
//

#import "SystemServicesConstants.h"

@interface SSAccelerometerInfo : NSObject

// Accelerometer Information

// Device Orientation
+ (UIDeviceOrientation)DeviceOrientation;

// Accelerometer X Value
+ (float)AccelerometerXValue;

// Accelerometer Y Value
+ (float)AccelerometerYValue;

// Accelerometer Z Value
+ (float)AccelerometerZValue;

@end
