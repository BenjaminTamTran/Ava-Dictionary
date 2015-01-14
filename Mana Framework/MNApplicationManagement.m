//
//  MNApplicationManagement.m
//  Mana Framework
//
//  Created by Tam Tran on 2/20/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNApplicationManagement.h"
#import "MNCommonFunction.h"
#import "MNAppDelegate.h"
#import "MNLeftViewController.h"
#import "MNCenterViewController.h"
#import "MNRightViewController.h"
@implementation MNApplicationManagement

- (NSString *) processRESTRequest:(NSString *)request withparams:(NSMutableDictionary *)params{
    //exit the application
    if ([request rangeOfString:@"suspendapp"].location != NSNotFound)
    {
        return [self exitApplication];
    }
    if ([request rangeOfString:@"sendsms"].location != NSNotFound)
    {
        return [self sendSMS:params];
    }
    if ([request rangeOfString:@"executejs"].location != NSNotFound)
    {
        NSMutableDictionary *params2 = [[[NSMutableDictionary alloc] init] autorelease];
        //play mp3 file from URL
        NSArray *queryElements = [request componentsSeparatedByString:@"?script="];
        if ([queryElements count] > 1) {
            [params2 setObject:queryElements[1] forKey:@"param"];
        }
        return [self executejs:params2];
    }
    return @"{\"Result\":\"404\",\"Error\":\"No action found\"}";
}

- (NSString *) exitApplication{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
//    exit(0);
    [[UIApplication sharedApplication] suspend];
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", result, reason_to_fail];
//    executeJavaScriptOnMainThread(json);
    return json;
}

- (NSString *) sendSMS:(NSMutableDictionary*)params{
    MFMessageComposeViewController *controller = [[[MFMessageComposeViewController alloc] init] autorelease];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = (NSString*)[params objectForKey:@"message"];
        controller.recipients = [NSArray arrayWithObjects:@"0983 411 833", nil];
        controller.messageComposeDelegate = self;
        MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
        [[appDelegate.window rootViewController] presentModalViewController:controller animated:YES];
        return @"{\"Result\":\"200\",\"Error\":\"\"}";
    }
    return @"{\"Result\":\"420\",\"Error\":\"Device is not configured for sending SMS!\"}";
}

- (NSString *) executejs:(NSMutableDictionary*)params{
    NSString *script = (NSString*)[params objectForKey:@"param"];
    script = [script stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    dispatch_async(dispatch_get_main_queue(), ^{
        MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.javascript_to_run = script;
        appDelegate.run_java_script = YES;
        JASidePanelController *viewController  = [[JASidePanelController alloc] init];
        viewController.shouldDelegateAutorotateToVisiblePanel = NO;
        viewController.leftPanel = [[MNLeftViewController alloc] initWithNibName:@"MNLeftViewController" bundle:nil];
        viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MNCenterViewController alloc] init]];
        viewController.rightPanel = [[MNRightViewController alloc] init];
        viewController.sidePanelController.leftGapPercentage = 100;
        viewController.sidePanelController.rightGapPercentage = 100;
        appDelegate.window.rootViewController = viewController;
        [appDelegate.window makeKeyAndVisible];
    });
    return @"{\"Result\":\"200\",\"Error\":\"\"}";
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *json;
    if (result == MessageComposeResultCancelled) {
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"User didn't send SMS\"}"];
    }else{
        json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"\",\"Data\":\"%@\"}", controller.body];
    }
    [[appDelegate.window rootViewController] dismissModalViewControllerAnimated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        appDelegate.json_media_state = json;
        appDelegate.register_media_state = YES;
        JASidePanelController *viewController  = [[JASidePanelController alloc] init];
        viewController.shouldDelegateAutorotateToVisiblePanel = NO;
        viewController.leftPanel = [[MNLeftViewController alloc] initWithNibName:@"MNLeftViewController" bundle:nil];
        viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MNCenterViewController alloc] init]];
        viewController.rightPanel = [[MNRightViewController alloc] init];
        viewController.sidePanelController.leftGapPercentage = 100;
        viewController.sidePanelController.rightGapPercentage = 100;
        appDelegate.window.rootViewController = viewController;
        [appDelegate.window makeKeyAndVisible];
        appDelegate.json_media_state = nil;
        appDelegate.register_media_state = NO;
    });
}


@end
