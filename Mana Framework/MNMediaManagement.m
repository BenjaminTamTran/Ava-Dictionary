//
//  MNMediaManagement.m
//  Mana portal
//
//  Created by Tam Tran on 2/7/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNMediaManagement.h"
#import "MNAppDelegate.h"
#import "MNLeftViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MNCommonFunction.h"
#import "MNCenterViewController.h"
@implementation MNMediaManagement
@synthesize url;
- (NSString *) processRESTRequest:(NSString *)request{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    //play mp3 file from URL
    NSArray *queryElements = [request componentsSeparatedByString:@"?"];
    if ([queryElements count] > 1) {
        NSArray *queryElements2 = [queryElements[1] componentsSeparatedByString:@"="];
        [params setObject:queryElements2[1] forKey:@"param"];
    }
    if ([request rangeOfString:@"playmp3"].location != NSNotFound)
    {
        return [self playMP3:params];
        
    }
    if ([request rangeOfString:@"getVolumn"].location != NSNotFound)
    {
        return [self getVolumn];
    }
    if ([request rangeOfString:@"pausemp3"].location != NSNotFound)
    {
        return [self pausemp3];
    }
    if ([request rangeOfString:@"resumemp3"].location != NSNotFound)
    {
        return [self resumemp3];
    }
    if ([request rangeOfString:@"registerstatechange"].location != NSNotFound)
    {
        return [self registerState:params];
    }
    if ([request rangeOfString:@"setVolumn"].location != NSNotFound)
    {
        return [self setVolumn:params];
    }
    if ([request rangeOfString:@"setVolumn"].location != NSNotFound)
    {
        return [self setVolumn:params];
    }
    if ([request rangeOfString:@"getstate"].location != NSNotFound)
    {
        return [self getState];
    }
    //stop mp3
    if ([request rangeOfString:@"stopmp3"].location != NSNotFound)
    {
        return [self stopmp3];
    }
    if ([request rangeOfString:@"camera"].location != NSNotFound)
    {
        return [self openCamera];
    }
    return @"[{\"Result\":\"404\",\"Error\":\"No action found\",}]";
}

- (NSString *) playMP3:(NSMutableDictionary*)params{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    NSString *url_song = [[NSURL alloc] initWithString:(NSString*)[params objectForKey:@"param"]];
    if (url_song != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void) {
            MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
            if (appDelegate.audioPlayer != nil){
                [appDelegate.audioPlayer stop];
                appDelegate.audioPlayer = nil;
            }
            [self mediaStateChange:0];
            NSData *songFile = [[[NSData alloc] initWithContentsOfURL:url_song options:NSDataReadingMappedIfSafe error:nil] autorelease];
            appDelegate.audioPlayer = [[AVAudioPlayer alloc] initWithData:songFile error:nil];
            appDelegate.audioPlayer.delegate = self;
            [appDelegate.audioPlayer play];
            [self mediaStateChange:1];
        });
    }else{
        return @"[{\"Result\":\"404\",\"Error\":\"mp3 source is wrong \"}]";
    }
    NSString *json = [[NSString alloc] initWithFormat:@"[{\"Result\":\"%@\",\"Error\":\"%@\"}]", result, reason_to_fail];
    return json;
}

- (NSString *) stopmp3{
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *json;
    if (appDelegate.audioPlayer != nil){
        [appDelegate.audioPlayer stop];
        json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
        [self mediaStateChange:3];
    }
    else{
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"No MP3 playing\"}"];
    }
    return json;
}

- (NSString *) getVolumn{
    NSString *json;
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.audioPlayer != nil){
        json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\":\"%.1f\"}", [appDelegate.audioPlayer volume]];
    }
    else
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"No MP3 playing\"}"];
    return json;
}

- (NSString *) pausemp3{
    NSString *json;
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.audioPlayer != nil){
        [appDelegate.audioPlayer pause];
        [self mediaStateChange:2];
        json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
    }
    else
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"No MP3 playing\"}"];
    return json;
}

- (NSString *) resumemp3{
    NSString *json;
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.audioPlayer != nil){
        [appDelegate.audioPlayer play];
        [self mediaStateChange:1];
        json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
    }
    else
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"No MP3 playing\"}"];
    return json;
}

- (NSString *) getState{
    NSString *json;
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    switch (appDelegate.audio_state) {
        case 0:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\": \"Buffering data\"}"];
            break;
        case 1:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\": \"Playing\"}"];
            break;
        case 2:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\": \"Pause\"}"];
            break;
        case 3:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\": \"Stop\"}"];
            break;
        case 4:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\", \"Data\": \"Finish\"}"];
            break;
        default:
            json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"No MP3 playing\"}"];
            break;
    }
    return json;
}

-(void) mediaStateChange:(int)state{
    //0: audio downloading
    //1: audio playing
    //2: audio pausing
    //3: audio stop
    //4: audio finish playing
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.audio_state = state;
    if (appDelegate.register_media_state == YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            appDelegate.json_media_state = [self getState];
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
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self mediaStateChange:4];
}

- (NSString *) setVolumn:(NSMutableDictionary*)params{
    NSError *error;
    NSString *json;
    NSString *level = (NSString*)[params objectForKey:@"param"];
    if ([[NSScanner scannerWithString:level] scanFloat:NULL]) {
        MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.audioPlayer != nil){
            [appDelegate.audioPlayer setVolume:[level floatValue]];
            json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
        }
        else
            json = [[NSString alloc] initWithString:@"{\"Result\":\"502\",\"Error\":\"No MP3 playing\"}"];
    }else{
        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"Volumn level is in wrong format, please use 0.7 for example.\"}"];
    }
    return json;
}

- (NSString *) registerState:(NSMutableDictionary*)params{
    NSString *json;
    NSString *registerState = (NSString*)[params objectForKey:@"param"];
    registerState = [registerState lowercaseString];
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([registerState isEqualToString:@"yes"]) {
        appDelegate.register_media_state = YES;
        json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
        return json;
    }
    appDelegate.register_media_state = NO;
    appDelegate.json_media_state = nil;
    if ([registerState isEqualToString:@"no"]) {
        json = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
        return json;
    }
    json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"Wrong param, should be 'yes' or 'no'\"}"];
    return json;
}

//- (NSString *) openCamera{
//    //path to image
//    CFUUIDRef uuidObj = CFUUIDCreate(nil);
//    // Get the string representation of the UUID
//    NSString *strImageName = (NSString*)CFUUIDCreateString(nil, uuidObj);
//    CFRelease(uuidObj);
//    //Call Function to save image to document directory
//    NSArray* arrAllDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString* strDocumentDirectory = [arrAllDirectories objectAtIndex:0];
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    NSString *result = [strDocumentDirectory stringByAppendingPathComponent:[strImageName stringByAppendingString:@".jpg"]];
//    path_to_pic = [[NSString alloc] initWithString:result];
//    
//    NSString *reason_to_fail = @"";
////    [self openCameraThread];
////    [self performSelectorOnMainThread:@selector(openCameraThread) withObject:nil waitUntilDone:NO];
//    //wait until camera done
//    cameraDone_status = @"None";
//    while ([cameraDone_status isEqualToString:@"None"]) {
//        sleep(1);
//    }
//    NSString *json;
//    if (cameraDone_status == 1) {
//        json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"%@\",\"image_path\":\"%@\"}", reason_to_fail, result];
//    }else{
//        json = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"User cancel camera\",\"image_path\":\"\"}"];
//    }
//    
////    executeJavaScriptOnMainThread(json);
//    return json;
//}

//-(void)openCameraThread
//{
//    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
//    controller.delegate = self;
//    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
//    controller.allowsEditing = NO;
//    [view_calling presentModalViewController:controller animated:YES];
////    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
////    [(MNLeftViewController*)[appDelegate.window rootViewController] presentModalViewController:controller animated:YES];
//    [controller release];
//}
//
//-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
//    UIImage* current_image = [info objectForKey: UIImagePickerControllerOriginalImage];
//    NSData* imgData = UIImageJPEGRepresentation(current_image, 1.0);
//    NSFileManager* fileManager = [NSFileManager defaultManager];
//    NSLog(@"%@", path_to_pic);
//    if(![fileManager fileExistsAtPath:path_to_pic])
//        [fileManager createFileAtPath:path_to_pic contents:imgData attributes:nil];
//    //close camera
//    cameraDone_status = 1;
//    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[appDelegate.window rootViewController] dismissModalViewControllerAnimated:YES];
//}
//
////if user is cancelling the camera
//-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    cameraDone_status = 2;
//    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
//    [[appDelegate.window rootViewController] dismissModalViewControllerAnimated:YES];
//}
@end
