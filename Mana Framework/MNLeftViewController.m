//
//  MNLeftViewController.m
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import "MNLeftViewController.h"
#import "JASidePanelController.h"

#import "UIViewController+JASidePanel.h"
#import "MNRightViewController.h"
#import "MNCenterViewController.h"
#import "MNMediaManagement.h"
#import "MNApplicationManagement.h"
#import "MNSystemInfoManager.h"
#import "MNToastManagement.h"
#import "MNFileManagement.h"
#import "MNDatabaseManagement.h"
#import "MNVibrate.h"
#import "MNScreenshot.h"
#import "MNAppDelegate.h"
#import "MNDownloadQueue.h"
#import "MNGETMethod.h"
#import "MNDELETEMethod.h"

@interface MNLeftViewController (){
}

@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *hide;
@property (nonatomic, weak) UIButton *show;
@property (nonatomic, weak) UIButton *removeRightPanel;
@property (nonatomic, weak) UIButton *addRightPanel;
@property (nonatomic, weak) UIButton *changeCenterPanel;

@end

@implementation MNLeftViewController

@synthesize javascriptBridge = _bridge;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Home Page";
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 290, 480)];
    webView.delegate = self;
    webView.scrollView.bounces = NO;
    [self.view addSubview:webView];
    
    [WebViewJavascriptBridge enableLogging];
    
    _bridge = [WebViewJavascriptBridge bridgeForWebView:webView handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"ObjC received message from JS: %@", data);
        //[self onTapNavigationMain];
        NSString *stringTemp = data;
        NSDictionary *dicJson;
        dicJson = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *api_dict_string = [dicJson objectForKey:@"dict_api_type"];
        if ([api_dict_string isEqualToString:@"save_function_and_move_to_center"]) {
            MNSetFocusScreen *controller = [[MNSetFocusScreen alloc] init];
            NSString *ret_data = [controller navigateAndFocusWithScreenNumber:5 withURL:@"" withController:self];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *function_name = [dicJson objectForKey:@"function_name"];
            [defaults setObject:function_name forKey:@"function_name"];
            return;
        }
        if([stringTemp rangeOfString:@"sendemail"].location != NSNotFound || [stringTemp rangeOfString:@"viewdetail"].location != NSNotFound)
        {
            stringTemp = [stringTemp stringByReplacingOccurrencesOfString:@"\"[" withString:@"["];
            stringTemp = [stringTemp stringByReplacingOccurrencesOfString:@"]\"" withString:@"]"];
            dicJson = [NSJSONSerialization JSONObjectWithData:[stringTemp dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
        else
        {
            dicJson = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        }
        
        NSString *api_string = [dicJson objectForKey:@"api"];
        NSString *json_data = @"{\"Result\":\"404\",\"Error\":\"No action found\"}";
        //FRAMEWORK: MEDIA
        if (([api_string rangeOfString:@"media"].location != NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSString *param;
            if ([dicJson count] > 1) {
                if ([api_string isEqualToString:@"media_playmp3"])
                {
                    param = [(NSDictionary *)[dicJson objectForKey:@"params"] objectForKey:@"source"];
                }
                if ([api_string isEqualToString:@"media_setVolumn"])
                {
                    param = [(NSDictionary *)[dicJson objectForKey:@"params"] objectForKey:@"value"];
                }
                if ([api_string isEqualToString:@"media_registerstatechange"])
                {
                    param = [(NSDictionary *)[dicJson objectForKey:@"params"] objectForKey:@"register"];
                }
                request = [[NSString alloc] initWithFormat:@"%@?source=%@", api_string, param];
            }else{
                request = api_string;
            }
            MNMediaManagement *media = [[MNMediaManagement alloc] init];
            if ([request rangeOfString:@"camera"].location != NSNotFound)
            {
                [self openCameraThread];
                return;
            }else{
                json_data = [media processRESTRequest:request];
            }
        }
        //FRAMEWORK: APPLICATION
        if (([api_string rangeOfString:@"application"].location != NSNotFound) && dicJson != nil)
        {
            if ([api_string isEqualToString:@"application_executejs"]) {
                if ([dicJson count] > 1) {
                    NSString *script = [(NSDictionary *)[dicJson objectForKey:@"params"] objectForKey:@"script"];
                    [_bridge send:script responseCallback:^(id response) {
                        
                    }];
                    //                json_data = [[NSString alloc] initWithString:@"{\"Result\":\"200\",\"Error\":\"\"}"];
                    return;
                }
            }
            MNApplicationManagement *app = [[MNApplicationManagement alloc] init];
            if ([api_string isEqualToString:@"application_sendsms"]) {
                if ([dicJson count] > 1) {
                    json_data = [app processRESTRequest:api_string withparams:(NSMutableDictionary *)[dicJson objectForKey:@"params"]];
                }
            }else{
                json_data = [app processRESTRequest:api_string withparams:nil];
            }
        }
        //END FRAMEWORK
        //FRAMEWORK: DATABASE
        if (([api_string rangeOfString:@"database"].location != NSNotFound) && dicJson != nil)
        {
            MNDatabaseManagement *database = [[MNDatabaseManagement alloc] init];
            if ([dicJson count] > 1) {
                json_data = [database executeSQL:(NSMutableDictionary *)[dicJson objectForKey:@"params"]];
            }else{
                json_data = [[NSString alloc] initWithString:@"{\"Result\":\"404\",\"Error\":\"Lack of parameter\"}"];
            }
        }
        //END FRAMEWORK
                
        //FRAMEWORK: SYSTEMINFO
        if (([api_string rangeOfString:@"getsysteminfo"].location != NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] > 1) {
                if ([[[dicJson objectForKey:@"params"]objectForKey:@""] isEqualToString:@""]) {
                    request = [[NSString alloc] initWithFormat:@"%@?UID=%@", api_string_arr[1], @""];
                }
                else
                {
                    request = [[NSString alloc] initWithFormat:@"%@?UID=%@", api_string_arr[1], [[dicJson objectForKey:@"params"]objectForKey:@"uid"]];
                }
                
            }else{
                request = [[NSString alloc] initWithFormat:@"%@?UID=%@", api_string_arr[1], @""];
            }
            MNSystemInfoManager *info = [[MNSystemInfoManager alloc] init];
            json_data = [info processRESTRequest:request];
        }
        //END FRAMEWORK
        //FRAMEWORK: VIBRATE
        if (([api_string rangeOfString:@"vibrate"].location != NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] > 1) {
                request = [[NSString alloc] initWithFormat:@"%@?Intensity=%@&time1=%@&time2=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"intensity"],[[dicJson objectForKey:@"params"]objectForKey:@"starttime"],[[dicJson objectForKey:@"params"]objectForKey:@"nexttime"]];
            }
            else
            {
                request = [[NSString alloc] initWithFormat:@"%@?UID=%@", api_string_arr[1],@""];
            }
            MNVibrate *vib = [[MNVibrate alloc] init];
            json_data = [vib processRESTRequest:request];
        }
        //END FRAMEWORK
        //FRAMEWORK:TOAST
        if (([api_string rangeOfString:@"toast"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] >1) {
                request = [[NSString alloc] initWithFormat:@"%@?body=%@&duration=%@&position=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"body"],[[dicJson objectForKey:@"params"]objectForKey:@"duration"],[[dicJson objectForKey:@"params"]objectForKey:@"position"]];
            }
            else
            {
                request = [[NSString alloc] initWithFormat:@"%@?body=%@&duration=%@&position=%@",api_string_arr[1],@"Show Toast Alert!",@"2",@"Bottom"];
            }
            MNToastManagement *toast = [[MNToastManagement alloc] init];
            json_data = [toast processRESTRequest:request];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: ZipFile
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"zipfile"])
        {
            NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentRootPath = [documentPaths objectAtIndex:0];
            
            NSString *destinationPath = [[dicJson objectForKey:@"params"] objectForKey:@"destinationpath"];
            NSArray *sourcePath = [NSJSONSerialization JSONObjectWithData:[[[dicJson objectForKey:@"params"] objectForKey:@"sourcepath"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray *arrayTemp = [sourcePath mutableCopy];
            //NSMutableArray *arrayTemp = [NSMutableArray array];
            [arrayTemp addObject:@"Abc.txt"];
            for (int i = 0 ; i < arrayTemp.count; i++)
            {
                [arrayTemp setObject:[documentRootPath stringByAppendingPathComponent:[arrayTemp objectAtIndex:i]] atIndexedSubscript:i];
            }
            
            [SSZipArchive createZipFileAtPath:[documentRootPath stringByAppendingPathComponent:destinationPath] withFilesAtPaths:arrayTemp];
            json_data = [SSZipArchive httpStatusCode];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: UnZipFile
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"unzipfile"])
        {
            NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentRootPath = [documentPaths objectAtIndex:0];
            NSString *destinationPath = [[dicJson objectForKey:@"params"] objectForKey:@"destinationpath"];
            NSString *sourcePath = [[dicJson objectForKey:@"params"] objectForKey:@"sourcepath"];
            [SSZipArchive unzipFileAtPath:[documentRootPath stringByAppendingPathComponent:sourcePath] toDestination:[documentRootPath stringByAppendingPathComponent:destinationPath]];
            json_data = [SSZipArchive httpStatusCode];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: ReadZipFile
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"readzipfile"])
        {
            NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentRootPath = [documentPaths objectAtIndex:0];
            NSString *destinationPath = [[dicJson objectForKey:@"params"] objectForKey:@"filename"];
            NSString *sourcePath = [[dicJson objectForKey:@"params"] objectForKey:@"url"];
            MNReadZIP *readZip = [[MNReadZIP alloc]init];
            json_data = [readZip readZIPFileWithURL:[documentRootPath stringByAppendingPathComponent:sourcePath] withFileNameToRead:destinationPath];
            //json_data = [SSZipArchive httpStatusCode];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: FILE
        if (([api_string rangeOfString:@"MNfile"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] > 1) {
                if ([api_string_arr[1] isEqualToString:@"download"]) {
                    request = [[NSString alloc] initWithFormat:@"%@?url=%@&path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"url"],[[dicJson objectForKey:@"params"]objectForKey:@"path"]];
                }
                else if ([api_string_arr[1] isEqualToString:@"rename"])
                {
                    request = [[NSString alloc] initWithFormat:@"%@?url=%@&path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"oldpath"],[[dicJson objectForKey:@"params"]objectForKey:@"newpath"]];
                }
                else if ([api_string_arr[1] isEqualToString:@"create"])
                {
                    if ([[[dicJson objectForKey:@"params"]objectForKey:@"body_filename"] isEqualToString:@""]) {
                        request = [[NSString alloc] initWithFormat:@"%@?url=%@&path=%@", api_string_arr[1],@"",[[dicJson objectForKey:@"params"]objectForKey:@"path"]];
                    }
                    else
                    {
                        request = [[NSString alloc] initWithFormat:@"%@?url=%@&path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"body_filename"],[[dicJson objectForKey:@"params"]objectForKey:@"path"]];
                    }
                }
                else
                {
                    request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1], [[dicJson objectForKey:@"params"]objectForKey:@"path"]];
                }
            }
            else
            {
                request = api_string_arr[1];
            }
            MNFileManagement *file_ = [[MNFileManagement alloc] init];
            json_data = [file_ processRESTRequest:request];
        }
        //END FRAMEWORK
        //SCREENSHOT
        if (([api_string rangeOfString:@"screenshot"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count]>1)
            {
                if ([[[dicJson objectForKey:@"params"]objectForKey:@"path"] isEqualToString:@""])
                {
                    request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1], @""];
                }
                else
                {
                    request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"path"]];
                }
            }
            else
            {
                request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1], @""];
            }
            MNScreenshot *ScreenShot = [[MNScreenshot alloc] init];
            json_data = [ScreenShot processRESTRequest:request];
        }
        //END
        //MapFolder(localPath,httpPath)
        if (([api_string rangeOfString:@"mapfolder"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] >1) {
                if ([[[dicJson objectForKey:@"params"]objectForKey:@"httppath"] isEqualToString:@""]) {
                    request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"localpath"]];
                }
                else
                {
                    request = [[NSString alloc] initWithFormat:@"%@?%@&localpath=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"httppath"],[[dicJson objectForKey:@"params"]objectForKey:@"localpath"]];
                }
            }
            else
            {
                request = api_string_arr[1];
            }
            MNFileManagement *file_ = [[MNFileManagement alloc] init];
            json_data = [file_ processRESTRequest:request];
        }
        //END
        //DOWNLOADQueue
        if (([api_string rangeOfString:@"downloadqueue"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *request;
            NSArray *api_string_arr=[[dicJson objectForKey:@"api"] componentsSeparatedByString:@"_"];
            if ([dicJson count] > 1) {
                request = [[NSString alloc] initWithFormat:@"%@?url=%@&path=%@", api_string_arr[1],[[dicJson objectForKey:@"params"]objectForKey:@"Arrayurls"],[[dicJson objectForKey:@"params"]objectForKey:@"localpath"]];
            }else
            {
                request = [[NSString alloc] initWithFormat:@"%@?path=%@", api_string_arr[1], @""];
            }
            MNDownloadQueue *downloadQ = [[MNDownloadQueue alloc] init];
            json_data = [downloadQ processRESTRequest:request];
        }
        //END


        //FRAMEWORK: Set Focus
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"setfocus"])
        {
            MNSetFocusScreen *controller = [[MNSetFocusScreen alloc] init];
            json_data = [controller navigateAndFocusWithScreenNumber:[[[dicJson objectForKey:@"params"] objectForKey:@"screennumber"] intValue] withURL:[[dicJson objectForKey:@"params"] objectForKey:@"url"] withController:self];
            return;
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Get Focus
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"getfocus"])
        {
            MNGetFocusScreen *controller = [[MNGetFocusScreen alloc] init];
            json_data = [controller getScreenNumber];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: View Detail
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"viewdetail"])
        {
            NSArray *arrayURL = [[dicJson objectForKey:@"params"] objectForKey:@"urls"];
            if(arrayURL.count == 0 || arrayURL == nil)
            {
                json_data = [[NSString alloc] initWithFormat:@"{\"Result\":\"450\",\"Error\":\"URL is NULL\"}"];
            }
            else
            {
                MNViewDetailViewController *controller = [[MNViewDetailViewController alloc] initWithNibName:@"MNViewDetailViewController" bundle:nil withArrayURL:arrayURL withIndex:[[[dicJson objectForKey:@"params"] objectForKey:@"index"] intValue]];
                [self _hideTapped];
                [self.navigationController pushViewController:controller animated:YES];
            }
            return;
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Google Analytics
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"setGoogleAnalytics"])
        {
//            MNGoogleAnalytics *analytic = [[MNGoogleAnalytics alloc]init];
//            json_data = [analytic googleAnalyticsInitializingWithTrackUncaughtExceptions:YES andDispatchInterval:5 andDebug:YES andTrackingID:[[dicJson objectForKey:@"params"] objectForKey:@"id"]];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: GPS
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"gps"])
        {
            MNGPS *controller = [[MNGPS alloc]init];
            json_data = [controller getGPS];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Notification
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"notification"])
        {
            MNNotification *controller = [[MNNotification alloc]init];
            json_data = [controller setNotificationWithPath:[[dicJson objectForKey:@"params"] objectForKey:@"secondsfromnow"] andBody:[[dicJson objectForKey:@"params"] objectForKey:@"body"]];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Icon Badge
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"iconbadge"])
        {
            MNIconBadgeNumber *controller = [[MNIconBadgeNumber alloc]init];
            json_data  = [controller setIconBadgeNumber:[[dicJson objectForKey:@"params"] objectForKey:@"badgenumber"]];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: MD5
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"md5"])
        {
            MNMD5 *controller = [[MNMD5 alloc]init];
            json_data  = [controller getMD5:[[dicJson objectForKey:@"params"] objectForKey:@"text"]];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Email
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"sendemail"])
        {
            NSArray *array = [[dicJson objectForKey:@"params"] objectForKey:@"mailto"];
            [self onTapEmailWithSubject:[[dicJson objectForKey:@"params"] objectForKey:@"emailsubject"] withMailTo:array withMessageBody:[[dicJson objectForKey:@"params"] objectForKey:@"messagebody"]];
            return;
        }
        //END FRAMEWORK
        
        //FRAMEWORK: Splash Screen
        if ([[dicJson objectForKey:@"api"] isEqualToString:@"setsplashscreen"])
        {
            MNSplashScreen *splashscreen = [[MNSplashScreen alloc]init];
            if([[[dicJson objectForKey:@"params"] objectForKey:@"status"] isEqualToString:@"On"])
            {
                [splashscreen saveStateSplashScreen:@"on"];
                [splashscreen saveImageURL:[[dicJson objectForKey:@"params"] objectForKey:@"url"] withTimeDelay:[[dicJson objectForKey:@"params"] objectForKey:@"timedelay"]];
            }
            else
            {
                [splashscreen saveStateSplashScreen:@"off"];
            }
            json_data = [splashscreen httpStatusCode];
        }
        //END FRAMEWORK

        //FRAMEWORK: POST METHOD
        if ([[[dicJson objectForKey:@"parameters"]objectForKey:@"method"] isEqualToString:@"POST"])
        {
            MNPOSTMethod *postMethod = [[MNPOSTMethod alloc]initWithWebViewJavascriptBridge:self.javascriptBridge];
            json_data = [postMethod requestPostMethodWithJSON:[dicJson mutableCopy]];
            //return;
        }
        //END FRAMEWORK
        
        //FRAMEWORK: PUT METHOD
        if ([[[dicJson objectForKey:@"parameters"]objectForKey:@"method"] isEqualToString:@"PUT"])
        {
            MNPUTMethod *putMethod = [[MNPUTMethod alloc]initWithWebViewJavascriptBridge:self.javascriptBridge];
            json_data = [putMethod requestPutMethodWithJSON:[dicJson mutableCopy]];
        }
        //END FRAMEWORK
        
        //FRAMEWORK: GET METHOD
        if ([[[dicJson objectForKey:@"parameters"]objectForKey:@"method"] isEqualToString:@"get"])
        {
            MNGETMethod *GETMethod = [[MNGETMethod alloc]initWithWebViewJavascriptBridge:self.javascriptBridge];
            json_data = [GETMethod requestGETMethodWithJSON:[dicJson mutableCopy]];
        }
        //END FRAMEWORK
        //FRAMEWORK: DELETE METHOD
        if ([[[dicJson objectForKey:@"parameters"]objectForKey:@"method"] isEqualToString:@"delete"])
        {
            MNDELETEMethod *DELETEMethod = [[MNDELETEMethod alloc]initWithWebViewJavascriptBridge:self.javascriptBridge];
            json_data=[DELETEMethod requestDELETEMethodWithJSON:[dicJson mutableCopy]];
        }
        //END FRAMEWORK

        if ([[[dicJson objectForKey:@"parameters"]objectForKey:@"method"] isEqualToString:@"FILE"])
        {
            NSString *request1=[[NSString alloc]initWithFormat:@"%@?path=%@",[[dicJson objectForKey:@"parameters"]objectForKey:@"url"],[[dicJson objectForKey:@"parameters"]objectForKey:@"localFile"]];
            MNFileManagement *file_ = [[MNFileManagement alloc] init];
            json_data = [file_ processRESTRequest:request1];
            
            // json_data = [splashscreen httpStatusCode];
        }


        /*if (([api_string rangeOfString:@"HTTPRequest"].location !=NSNotFound) && dicJson != nil)
        {
            NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *url=[[dicJson objectForKey:@"parameters"] objectForKey:@"url"];
            NSString *method=[[dicJson objectForKey:@"parameters"] objectForKey:@"method"];
            NSString *localfile=[[dicJson objectForKey:@"parameters"] objectForKey:@"localFile"];
            docDir=[docDir stringByAppendingPathComponent:localfile];
            NSMutableDictionary *header=[[dicJson objectForKey:@"parameters"]objectForKey:@"header"];
            NSString *proxyhost=[[[dicJson objectForKey:@"parameters"]objectForKey:@"proxies"]objectForKey:@"host"];
            NSTimeInterval timeout = [[[dicJson objectForKey:@"parameters"]objectForKey:@"timeout"] doubleValue];
            
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
            [request setRequestMethod:method];
            [request setDownloadDestinationPath:docDir];
            [request setRequestHeaders:header];
            [request setProxyHost:proxyhost];
            [request setTimeOutSeconds:timeout];
            [request setUseCookiePersistence:true];
            [request setUserAgentString:@"Chrome"];
            [request setUseSessionPersistence:true];
            [request setDidFinishSelector:@selector(Showfinish:)];
            [request setDidFailSelector:@selector(Showerror:)];
            [request setDelegate:self];
            [request startAsynchronous];
            NSString *request1=@"list?path=";
            MNFileManagement *file_ = [[MNFileManagement alloc] init];
            json_data = [file_ processRESTRequest:request1];
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
             [request setRequestMethod:method];
             //[request appendPostData:[@"some body params" dataUsingEncoding:NSUTF8StringEncoding]];
             [request setDidFinishSelector:@selector(Showfinish:)];
             [request setDidFailSelector:@selector(Showerror:)];
             [request setDelegate:self];
             [request startSynchronous];
             json_data = @"ABC";
        }*/
        //END
        
        
        [self openMainViewAndDisplayJson:json_data];
    }];
    
    [_bridge registerHandler:@"testObjcCallback" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"testObjcCallback called: %@", data);
        responseCallback(@"Response from testObjcCallback");
    }];
    
    //[self renderButtons:webView];
    [self loadExamplePage:webView];
    //check if register media state and send data
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ((appDelegate.run_java_script == YES) && (appDelegate.javascript_to_run != nil)) {
        [_bridge send:appDelegate.javascript_to_run responseCallback:^(id response) {
            
        }];
        appDelegate.run_java_script = NO;
        appDelegate.javascript_to_run = nil;
    }
    
    //    [_bridge send:@"A string sent from ObjC after Webview has loaded."];
    
}


-(void)openCameraThread
{
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.allowsEditing = NO;
    [self presentModalViewController:controller animated:YES];
    [controller release];
}

-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* current_image = [info objectForKey: UIImagePickerControllerOriginalImage];
    NSData* imgData = UIImageJPEGRepresentation(current_image, 1.0);
    NSFileManager* fileManager = [NSFileManager defaultManager];
    //path to image
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    // Get the string representation of the UUID
    NSString *strImageName = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    //Call Function to save image to document directory
    NSArray* arrAllDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* strDocumentDirectory = [arrAllDirectories objectAtIndex:0];
    NSString *result = [strDocumentDirectory stringByAppendingPathComponent:[strImageName stringByAppendingString:@".jpg"]];
    NSString *path_to_pic = [[NSString alloc] initWithString:result];
    
    if(![fileManager fileExistsAtPath:path_to_pic])
        [fileManager createFileAtPath:path_to_pic contents:imgData attributes:nil];
    //close camera
    [self dismissModalViewControllerAnimated:YES];
    NSString *json_data = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"\",\"image_path\":\"%@\"}", path_to_pic];
    [self openMainViewAndDisplayJson:json_data];
}

//if user is cancelling the camera
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
    NSString *json_data = [[NSString alloc] initWithString:@"{\"Result\":\"402\",\"Error\":\"User cancel camera\",\"image_path\":\"\"}"];
    [self openMainViewAndDisplayJson:json_data];
}

- (void)openMainViewAndDisplayJson:(NSString *)json{
    MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
    //    controller.urlString = @"http://www.google.com";
    //controller.json_data = json;
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:controller];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *javascriptString = [[NSString alloc] initWithFormat:@"document.body.style.width = '280px';"];
    [webView stringByEvaluatingJavaScriptFromString:javascriptString];
}

- (void)_hideTapped
{
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
    self.hide.hidden = YES;
    self.show.hidden = NO;
    
}

- (void)_showTapped{
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
    self.hide.hidden = NO;
    self.show.hidden = YES;
}

- (void)renderButtons:(UIWebView*)webView {
    UIButton *messageButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[messageButton setTitle:@"Send message" forState:UIControlStateNormal];
	[messageButton addTarget:self action:@selector(sendMessage:) forControlEvents:UIControlEventTouchUpInside];
	[self.view insertSubview:messageButton aboveSubview:webView];
	messageButton.frame = CGRectMake(20, 414, 130, 45);
    
    UIButton *callbackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [callbackButton setTitle:@"Call handler" forState:UIControlStateNormal];
    [callbackButton addTarget:self action:@selector(callHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:callbackButton aboveSubview:webView];
	callbackButton.frame = CGRectMake(170, 414, 130, 45);
}

- (void)sendMessage:(id)sender {
    [_bridge send:@"A string sent from ObjC to JS" responseCallback:^(id response) {
        NSLog(@"sendMessage got response: %@", response);
    }];
}

- (void)callHandler:(id)sender {
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"Hi there, JS!" forKey:@"greetingFromObjC"];
    [_bridge callHandler:@"testJavascriptHandler" data:data responseCallback:^(id response) {
        NSLog(@"testJavascriptHandler responded: %@", response);
    }];
}

- (void)loadExamplePage:(UIWebView*)webView {
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"Dictionary-Left" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:appHtml baseURL:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    MNGetFocusScreen *controller = [[MNGetFocusScreen alloc]init];
    [controller stateScreenWithScreenNumber:@"4"];
    [self.navigationController setNavigationBarHidden:YES];
    [self _showTapped];
}


#pragma mark - Button Actions


- (void)onTapEmailWithSubject:(NSString*)_subject withMailTo:(NSArray*)_mailTo withMessageBody:(NSString*)_mess
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:_subject];
    [mc setMessageBody:_mess isHTML:NO];
    [mc setToRecipients:_mailTo];
    [self presentViewController:mc animated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSString *json = @"";
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            json = [[NSString alloc] initWithFormat:@"{\"Result\":\"452\",\"Error\":\"Mail cancelled\"}"];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            json = [[NSString alloc] initWithFormat:@"{\"Result\":\"453\",\"Error\":\"Mail saved\"}"];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\"}"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"%@\"}",[error localizedDescription]];
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self openMainViewAndDisplayJson:json];
}

- (void)_hideTapped:(id)sender {
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
    self.hide.hidden = YES;
    self.show.hidden = NO;
}

- (void)_showTapped:(id)sender {
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
    self.hide.hidden = NO;
    self.show.hidden = YES;
}

- (void)_removeRightPanelTapped:(id)sender {
    self.sidePanelController.rightPanel = nil;
    self.removeRightPanel.hidden = YES;
    self.addRightPanel.hidden = NO;
}

- (void)_addRightPanelTapped:(id)sender {
    self.sidePanelController.rightPanel = [[MNRightViewController alloc] init];
    self.removeRightPanel.hidden = NO;
    self.addRightPanel.hidden = YES;
}

- (void)_changeCenterPanelTapped:(id)sender
{
    self.sidePanelController.centerPanel = [[MNCenterViewController alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapNavigationMain
{
    /*
     MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
     controller.urlString = @"http://www.yahoo.com";
     self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:controller];
     */
    MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
    [controller loadURLFromWeb:@"http://www.google.com"];
    [self.sidePanelController setCenterPanelHidden:YES animated:YES duration:0.2f];
    self.hide.hidden = YES;
    self.show.hidden = NO;
    
    [self.sidePanelController setCenterPanelHidden:NO animated:YES duration:0.2f];
    self.hide.hidden = NO;
    self.show.hidden = YES;
    //self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:controller];
}
- (void)onTapNavigationMainAndFocus
{
    MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
    //controller.urlString = @"http://www.google.com";
    self.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:controller];
}
- (void)onTapNavigationRight
{
    MNRightViewController *controller = [[MNRightViewController alloc]initWithNibName:@"MNRightViewController" bundle:nil];
    controller.urlString = @"http://www.vnexpress.vn";
    self.sidePanelController.rightPanel = controller;
}
- (void)onTapNavigationRightAndFocus
{
    MNRightViewController *controller = [[MNRightViewController alloc]initWithNibName:@"MNRightViewController" bundle:nil];
    controller.urlString = @"http://a.p.mana.vn/news/dsnews_web?lft=256&root=30";
    self.sidePanelController.rightPanel = controller;
    [self.sidePanelController showRightPanel:YES];
}


@end
