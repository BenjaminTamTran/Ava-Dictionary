//
//  MNCommonFunction.m
//  Mana Framework
//
//  Created by Tam Tran on 2/22/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNCommonFunction.h"
#import "MNAppDelegate.h"
#import "MNViewController.h"
NSString *script_data;
NSString *script_data_timing;
NSString *script_type_timing;
void executeJavaScriptOnMainThread(NSString *content){
    NSString *timestamp = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    exposeTiming(@"timing2",timestamp);
    script_data = [[NSString alloc] initWithString:content];
    dispatch_async(dispatch_get_main_queue(), ^{
        runJavaScript(@"result");
        NSString *timestamp = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        exposeTiming(@"timing3",timestamp);
    });
}

void exposeTiming(NSString *type, NSString *timing){
    script_type_timing = [[NSString alloc] initWithString:type];
    script_data_timing = [[NSString alloc] initWithString:timing];
    dispatch_async(dispatch_get_main_queue(), ^{
        runJavaScript(@"timing");
    });
}

void runJavaScript(NSString *type)
{
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    MNViewController *view = (MNViewController*)[[appDelegate window] rootViewController];
    NSString *javascriptString;
    if ([type isEqualToString:@"result"]) {
        javascriptString = [[NSString alloc] initWithFormat:@"document.getElementById('result').innerText = '%@';",script_data];
    }else{
        javascriptString = [[NSString alloc] initWithFormat:@"printTiming('%@', '%@');",script_type_timing, script_data_timing];
    }
    [view.web_view stringByEvaluatingJavaScriptFromString:javascriptString];
}

