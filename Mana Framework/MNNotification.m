//
//  MNNotification.m
//  Mana Framework
//
//  Created by Toan Le on 21/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNNotification.h"

@implementation MNNotification

-(NSString*)setNotificationWithPath:(NSString *)_seconds andBody:(NSString *)_body
{
    bool validDateString = [self textFieldValidation:_seconds];
    if (!validDateString)
    {
        NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
        return data;
    }
    
    NSString *dateString2 = _seconds;
    
    NSDate *currentDate = [NSDate date];
    
    NSDate *dateAfterAddSeconds = [currentDate dateByAddingTimeInterval:[dateString2 floatValue]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMyyyyHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString2];
    [dateFormatter release];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = dateAfterAddSeconds;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];

    localNotif.alertBody = _body;
        
    localNotif.alertAction = @"View";
    
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    
    [localNotif setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
    
    // Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    localNotif.userInfo = infoDict;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    //Return Respond
    NSString *data = [self httpStatusCode:@"200" withErrorMessage:@"OK"];
    return data;
    
}

-(NSString*)setNotificationWithPath2:(NSString*)path
{
    if([path rangeOfString:@"body="].location != NSNotFound && [path rangeOfString:@"secondsfromnow="].location != NSNotFound && [path rangeOfString:@"&time"].location == NSNotFound)
    {
        NSString *tempAlertBody = [path substringFromIndex:[path rangeOfString:@"body="].location];
        NSString *alertBody = [tempAlertBody substringFromIndex:5];
        alertBody = [alertBody substringToIndex:[alertBody rangeOfString:@"&secondsfromnow"].location];
        if([alertBody isEqualToString:@""])
        {
            NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
            return data;
        }
        
        NSString *temp = [path substringFromIndex:[path rangeOfString:@"secondsfromnow="].location];
        if([path rangeOfString:@"&sound"].location != NSNotFound)
        {
            temp = [temp substringToIndex:[temp rangeOfString:@"&sound"].location];
        }
        NSString *dateString = [temp substringFromIndex:15];
        
        if([dateString isEqualToString:@""])
        {
            NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
            return data;
        }
        else
        {
            bool validDateString = [self textFieldValidation:dateString];
            if (!validDateString)
            {
                NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
                return data;
            }
        }
        
        NSString *temp2 = [path substringFromIndex:[path rangeOfString:@"secondsfromnow="].location];
        if([path rangeOfString:@"&sound"].location != NSNotFound)
        {
            temp2 = [temp2 substringToIndex:[temp2 rangeOfString:@"&sound"].location];
        }
        
        NSString *dateString2 = [temp substringFromIndex:15];
        
        NSDate *currentDate = [NSDate date];
        
        NSDate *dateAfterAddSeconds = [currentDate dateByAddingTimeInterval:[dateString2 floatValue]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"ddMMyyyyHHmmss"];
        NSDate *dateFromString = [[NSDate alloc] init];
        dateFromString = [dateFormatter dateFromString:dateString2];
        [dateFormatter release];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate = dateAfterAddSeconds;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        NSString *tempAlertBody2 = [path substringFromIndex:[path rangeOfString:@"body="].location];
        NSString *alertBody2 = [tempAlertBody2 substringFromIndex:5];
        alertBody2 = [alertBody2 substringToIndex:[alertBody2 rangeOfString:@"&secondsfromnow"].location];
        
        if([alertBody2 isEqualToString:@""])
        {
            localNotif.alertBody = @"Notification";
        }
        else
        {
            localNotif.alertBody = [alertBody2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        localNotif.alertAction = @"View";
        
        if([path rangeOfString:@"&sound"].location != NSNotFound)
        {
            NSString *tempSoundName = [path substringFromIndex:[path rangeOfString:@"sound="].location];
            if(tempSoundName.length > 6)
            {
                NSString *soundName = [tempSoundName substringFromIndex:6];
                localNotif.soundName = soundName;
            }
            else
            {
                localNotif.soundName = UILocalNotificationDefaultSoundName;
            }
        }
        else
        {
            localNotif.soundName = UILocalNotificationDefaultSoundName;
        }
        
        [localNotif setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
        
        // Specify custom data for the notification
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        [localNotif release];
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
        //Return Respond
        NSString *data = [self httpStatusCode:@"200" withErrorMessage:@"OK"];
        return data;
        
    }
    
    if([path rangeOfString:@"body="].location == NSNotFound || [path rangeOfString:@"time="].location == NSNotFound)
    {
        NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
        return data;
    }
    else
    {
        NSString *tempAlertBody = [path substringFromIndex:[path rangeOfString:@"body="].location];
        NSString *alertBody = [tempAlertBody substringFromIndex:5];
        alertBody = [alertBody substringToIndex:[alertBody rangeOfString:@"&time"].location];
        if([alertBody isEqualToString:@""])
        {
            NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
            return data;
        }
        
        NSString *temp = [path substringFromIndex:[path rangeOfString:@"time="].location];
        if([path rangeOfString:@"&sound"].location != NSNotFound)
        {
            temp = [temp substringToIndex:[temp rangeOfString:@"&sound"].location];
        }
        NSString *dateString = [temp substringFromIndex:5];
        
        if([dateString isEqualToString:@""])
        {
            NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
            return data;
        }
        else
        {
            bool validDateString = [self textFieldValidation:dateString];
            if (!validDateString)
            {
                NSString *data = [self httpStatusCode:@"450" withErrorMessage:@"Wrong parameters"];
                return data;
            }
            
        }
        
    }
    
    NSString *temp = [path substringFromIndex:[path rangeOfString:@"time="].location];
    if([path rangeOfString:@"&sound"].location != NSNotFound)
    {
        temp = [temp substringToIndex:[temp rangeOfString:@"&sound"].location];
    }
    
    NSString *dateString = [temp substringFromIndex:5];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"ddMMyyyyHHmmss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:dateString];
    [dateFormatter release];
    
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = dateFromString;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    NSString *tempAlertBody = [path substringFromIndex:[path rangeOfString:@"body="].location];
    NSString *alertBody = [tempAlertBody substringFromIndex:5];
    alertBody = [alertBody substringToIndex:[alertBody rangeOfString:@"&time"].location];
    
    if([alertBody isEqualToString:@""])
    {
        localNotif.alertBody = @"Notification";
    }
    else
    {
        localNotif.alertBody = [alertBody stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    localNotif.alertAction = @"View";
    
    if([path rangeOfString:@"&sound"].location != NSNotFound)
    {
        NSString *tempSoundName = [path substringFromIndex:[path rangeOfString:@"sound="].location];
        if(tempSoundName.length > 6)
        {
            NSString *soundName = [tempSoundName substringFromIndex:6];
            localNotif.soundName = soundName;
        }
        else
        {
            localNotif.soundName = UILocalNotificationDefaultSoundName;
        }
    }
    else
    {
        localNotif.soundName = UILocalNotificationDefaultSoundName;
    }
    
    [localNotif setApplicationIconBadgeNumber:[[UIApplication sharedApplication] applicationIconBadgeNumber]+1];
    
    // Specify custom data for the notification
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"someValue" forKey:@"someKey"];
    localNotif.userInfo = infoDict;
    
    // Schedule the notification
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [localNotif release];
    //Return Respond
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
