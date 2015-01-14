//
//  MNSystemInfoManager.m
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/18/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNSystemInfoManager.h"
#import "MNCommonFunction.h"
#import <mach/mach_time.h>
@implementation MNSystemInfoManager
-(NSMutableDictionary*)request
{
    NSDictionary *SystemInformationDict = [SystemServices AllSystemInformation];
    return SystemInformationDict;
}
-(NSArray*)key
{
    NSDictionary *SystemInformationDict = [SystemServices AllSystemInformation];
    NSArray *SystemInformationArray = [SystemInformationDict allKeys];
    return SystemInformationArray;
}
- (NSString *) processRESTRequest:(NSString *)request{
    //uint64_t start;
    // Get all Information
    NSDictionary *SystemInformationDict = [SystemServices AllSystemInformation];
    // Convert to Array
    NSArray *SystemInformationArray = [SystemInformationDict allKeys];
    // Run through all the information about the system
    //NSString *SystemInfo=[[NSString alloc] init];
    //NSMutableArray *SystemInfo_=[[NSMutableArray alloc]init];
    NSString *result = @"OK";
    NSString *reason_to_fail = @"";
    NSError * error = nil;
    NSString *Data;
    if ([request rangeOfString:@"getinfo"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"="];
        if ([queryElements[[queryElements count]-1] isEqualToString:@""]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:SystemInformationDict options:0 error:&error];
            id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
            if (!json) {
                NSLog(@"JSON error: %@", error);
                result=@"Error";
            } else {
                Data= [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
            }
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
            return json_;
        }
        else
        {
            for (int y = 0; y <= SystemInformationArray.count - 1; y++) {
                if ([request rangeOfString:[SystemInformationArray objectAtIndex:y]].location != NSNotFound) {
                    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[SystemInformationDict objectForKey:[SystemInformationArray objectAtIndex:y]] forKey:[SystemInformationArray objectAtIndex:y]];
                    
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
                    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
                    if (!json) {
                        NSLog(@"JSON error: %@", error);
                        result=@"Error";
                    } else {
                        Data= [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
                    }
                    NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
                    return json_;
                }
            }
        }
    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
}
    @end