//
//  MNGPS.m
//  Mana Framework
//
//  Created by Toan Le on 21/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNGPS.h"

@implementation MNGPS

-(NSString*)getGPS
{
    NSUserDefaults *defaults = [[NSUserDefaults alloc]init];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"200" forKey:@"Result:"];
    [dic setObject:@"OK" forKey:@"Error:"];
    NSString *longitude = @"";
    NSString *latitude = @"";
    if([defaults objectForKey:@"longitude"] != nil && [defaults objectForKey:@"latitude"] != nil)
    {
        [dic setObject:[defaults objectForKey:@"longitude"] forKey:@"longitude"];
        [dic setObject:[defaults objectForKey:@"latitude"] forKey:@"latitude"];
        longitude = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"longitude"]];
        latitude = [NSString stringWithFormat:@"%@",[defaults objectForKey:@"latitude"]];
        NSString *string_=[[NSString alloc]initWithFormat:@"longitude: %@\nlatitide: %@",longitude,latitude];
        return string_;
    }
    if([longitude length] > 0 && [latitude length] > 0)
    {
        return [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\",\"longitude\":\"%@\",\"latitude\":\"%@\"}",longitude ,latitude ];
    }
    else
    {
        return [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"GPS Not Allow from User\",\"longitude\":\"%@\",\"latitude\":\"%@\"}",longitude ,latitude ];
    }
    
}

@end
