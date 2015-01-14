//
//  MNToastManagement.m
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/20/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNToastManagement.h"
#import "iKToast.h"
#import "MNCommonFunction.h"
#import <mach/mach_time.h>
uint64_t start;
@implementation MNToastManagement
- (NSString *) processRESTRequest:(NSString *)request{
    if ([request rangeOfString:@"message"].location != NSNotFound)
    {
        //start = mach_absolute_time();
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        if ([queryElements count]==1) {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"Error",@"No Data"];
            return json_;
        }
        NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
        NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
        NSString *body=queryElements2[1];
        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
        NSString *duration=queryElements3[1];
        NSArray *queryElements4=[queryElements1[2] componentsSeparatedByString:@"="];
        NSString *position=queryElements4[1];
        body=[body stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        if ([position isEqualToString:@"Top"]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                //Your code goes in here
                [iKToast showToastWithString:body duration:[duration intValue]withDistance:30 inPosition:[position intValue]];}];
        }
        else if ([position isEqualToString:@"Center"])
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                //Your code goes in here
                [iKToast showToastWithString:body duration:[duration intValue] withDistance:30 inPosition:iKToastPositionMiddle];}];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                //Your code goes in here
                [iKToast showToastWithString:body duration:[duration intValue]withDistance:30 inPosition:iKToastPositionBottom];
            }];
            
        }
        return [self showtoast:queryElements1];
    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
}

- (NSString *) showtoast:(NSArray*)JsonArray{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    NSError *error;
    NSString *Data;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JsonArray options:0 error:&error];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!json) {
        NSLog(@"JSON error: %@", error);
        result=@"Error";
    } else {
        Data= [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    }
    NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
    
   /* uint64_t end = mach_absolute_time();
    uint64_t elapsed = end - start;
    
    mach_timebase_info_data_t info;
    if (mach_timebase_info (&info) != KERN_SUCCESS) {
        printf ("mach_timebase_info failed\n");
    }
    
    uint64_t nanosecs = elapsed * info.numer / info.denom;
    uint64_t millisecs = nanosecs / 1000000;
    NSNumber* n = [NSNumber numberWithUnsignedLongLong:millisecs];
    NSString *militime=[n stringValue];
    n = [NSNumber numberWithUnsignedLongLong:nanosecs];
    NSString *nanotime=[n stringValue];
    NSString *time=[[NSString alloc] initWithFormat:@"%@ milli - %@ nano",militime,nanotime];
    executeJavaScriptOnMainThread(json_);
    //exposeTiming(time);*/
    return json_;
}
@end
