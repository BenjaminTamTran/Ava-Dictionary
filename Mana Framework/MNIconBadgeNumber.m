//
//  MNIconBadgeNumber.m
//  Mana Framework
//
//  Created by Toan Le on 21/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNIconBadgeNumber.h"

@implementation MNIconBadgeNumber

-(NSString*)setIconBadgeNumber:(NSString*)path
{
    //NSString *badgeNumber = [path substringFromIndex:[path rangeOfString:@"number/"].location];
    //badgeNumber = [badgeNumber substringFromIndex:7];
    NSString *badgeNumber = path;
    if(badgeNumber.length == 0)
    {
        NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong Parameters"];
        return data;
    }
    else
    {
        bool validNumber = [self textFieldValidation:badgeNumber];
        if(!validNumber)
        {
            NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong Parameters"];
            return data;
        }
    }
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:[badgeNumber integerValue]];
    
    NSString *data = [self httpStatusCode:@"200" withErrorMessage:@"OK"];
    return data;
}

-(NSString*)httpStatusCode:(NSString*)code withErrorMessage:(NSString*)_mess
{
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", code, _mess];
    //executeJavaScriptOnMainThread(json);
    return json;
}

-(BOOL) textFieldValidation:(NSString *)checkString
{
    NSString *stricterFilterString = @"[0-9]+";
    NSString *regEx =  stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [emailTest evaluateWithObject:checkString];
}

@end
