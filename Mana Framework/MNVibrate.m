//
//  MNVibrate.m
//  Mana Framework
//
//  Created by Tuan Truong Anh on 2/28/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNVibrate.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation MNVibrate
- (NSString *) processRESTRequest:(NSString *)request{
//    if ([request rangeOfString:@"pattern"].location != NSNotFound)
//    {
//        if ([[request componentsSeparatedByString:@"="][1] isEqualToString:@""]) {
//           AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",@""];
//            return json_;
//        }
//        else
//        {
//        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
//        NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
//        NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
//        NSString *Intensity=queryElements2[1];
//        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
//        NSString *time1=queryElements3[1];
//        NSArray *queryElements4=[queryElements1[2] componentsSeparatedByString:@"="];
//        NSString *time2=queryElements4[1];
//        return [self vibrate:Intensity :time1 :time2];
//        }
//    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
}
- (NSString *)vibrate:(NSString*)Intensity:(NSString*)time1:(NSString*)time2 {
//    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
//    NSMutableArray* arr = [NSMutableArray array ];
//    
//    [arr addObject:[NSNumber numberWithBool:YES]]; //vibrate for 2000ms
//    [arr addObject:[NSNumber numberWithInt:[time1 intValue]]];
//    
//    [arr addObject:[NSNumber numberWithBool:NO]];  //stop for 1000ms
//    [arr addObject:[NSNumber numberWithInt:1000]];
//    
//    [arr addObject:[NSNumber numberWithBool:YES]];  //vibrate for 1000ms
//    [arr addObject:[NSNumber numberWithInt:[time2 intValue]]];
//    
//    [arr addObject:[NSNumber numberWithBool:NO]];    //stop for 500ms
//    [arr addObject:[NSNumber numberWithInt:500]];
//    
//    [dict setObject:arr forKey:@"VibePattern"];
//    [dict setObject:[NSNumber numberWithInt:[Intensity intValue]] forKey:@"Intensity"];
//    AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate,nil,dict);
    //AudioServicesStopSystemSound();
    //AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",@""];
    return json_;
}

@end
