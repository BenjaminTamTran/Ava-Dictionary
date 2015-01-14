//
//  MNMD5.m
//  Mana Framework
//
//  Created by Toan Le on 28/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNMD5.h"

@implementation MNMD5

-(NSString*)getMD5:(NSString*)_string
{
    if(_string.length == 0 || _string == nil)
    {
        NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
        return data;
    }
    
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\",\"Data\":\"%@\"}",[_string MD5]];
    
    return json;
}

-(NSString*)httpStatusCode:(NSString*)code withErrorMessage:(NSString*)_mess
{
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", code, _mess];
    //executeJavaScriptOnMainThread(json);
    return json;
}

@end
