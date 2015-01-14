//
//  MNAppDelegate.m
//  Mana Framework
//
//  Created by Toan Le on 20/02/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNAppDelegate.h"
//#import <NewRelicAgent/NewRelicAgent.h>
#import "MNViewController.h"
#import "JASidePanelController.h"
#import "MNCenterViewController.h"
#import "MNLeftViewController.h"
#import "MNRightViewController.h"
#import "MNMainViewController.h"

#import "MNFile.h"
#import "SSZipArchive.h"
#import "MNGETMethod.h"
@implementation MNAppDelegate
@synthesize audioPlayer, toast, audio_state, register_media_state, json_media_state, run_java_script, javascript_to_run;
- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
//    // Override point for customization after application launch.
//
//   
//    //    
//    JASidePanelController *viewController  = [[JASidePanelController alloc] init];
//    viewController.shouldDelegateAutorotateToVisiblePanel = NO;
//    
//	viewController.leftPanel = [[UINavigationController alloc] initWithRootViewController:[[MNLeftViewController alloc] initWithNibName:@"MNLeftViewController" bundle:nil]];
//	viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MNCenterViewController alloc] init]];
//	viewController.rightPanel = [[MNRightViewController alloc] init];
//	
//    
//    viewController.sidePanelController.leftGapPercentage = 100;
//    viewController.sidePanelController.rightGapPercentage = 100;
//	self.window.rootViewController = viewController;
//    audio_state = 100;
//    register_media_state = NO;
//    run_java_script = NO;
//    [self startStopServer:false];
//    [self.window makeKeyAndVisible];
//    [MNSplashScreen startSplashScreen:self.window.rootViewController];
//    return YES;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    JASidePanelController *viewController  = [[JASidePanelController alloc] init];
    viewController.shouldDelegateAutorotateToVisiblePanel = NO;

//    TKFunctionGPS *fun = [[TKFunctionGPS alloc]init];
//    [fun getGPS];

//    [NewRelicAgent startWithApplicationToken:@"AA42d5c9b2fb9ab841a680d417ec6fc2d7d53954d6"];
    viewController.leftPanel = [[UINavigationController alloc] initWithRootViewController:[[MNLeftViewController alloc] initWithNibName:@"MNLeftViewController" bundle:nil]];
    viewController.centerPanel = [[UINavigationController alloc] initWithRootViewController:[[MNCenterViewController alloc] init]];
    viewController.rightPanel = [[MNRightViewController alloc] init];

    /*MNFile *datafile=[[MNFile alloc]init];
    if ([datafile checkDB:@"viet_anh.db"]==true && [datafile checkDB:@"anh_viet.db"]==true) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"First Call", nil)
                                                        message:NSLocalizedString(@"Downling Database, Wait", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        MNGETMethod *GETMethod = [[MNGETMethod alloc]init];
       [GETMethod requestWithString];
        }*/
    viewController.sidePanelController.leftGapPercentage  = 100;
    viewController.sidePanelController.rightGapPercentage = 100;
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)startStopServer:(bool)started
{
    if(started)
    {
        [httpServer stop];
    }
    httpServer = [[HTTPServer alloc] init];
    [httpServer setType:@"_http._tcp."];
    [httpServer setDocumentRoot:[NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]]];
    [httpServer setPort:8081];
    [httpServer setConnectionClass:[MyHTTPConnection class]];
    NSError *error;
    
    if(![httpServer start:&error])
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    else
    {
        //NSLog(@"Starting HTTP Server");
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self startStopServer:true];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
