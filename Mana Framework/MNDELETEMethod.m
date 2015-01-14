//
//  MNDELETEMethod.m
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/15/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNDELETEMethod.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "MNFile.h"
#import "MNCenterViewController.h"
#import "JASidePanelController.h"
NSString *docDir;
@implementation MNDELETEMethod
@synthesize bridge,requestFinish,requestError,requestStarted;
-(id)initWithWebViewJavascriptBridge:(WebViewJavascriptBridge *)_bridge
{
    self = [super init];
    if (self)
    {
        self.bridge = _bridge;
    }
    return self;
}
-(NSString *)requestDELETEMethodWithJSON:(NSMutableDictionary*)dic
{
    ASIHTTPRequest *request;
    if([dic objectForKey:@"parameters"]!=nil)
    {
        if([[dic objectForKey:@"parameters"] objectForKey:@"url"]!=nil)
        {
             //request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[dic objectForKey:@"parameters"] objectForKey:@"url"]]];
            if([[dic objectForKey:@"parameters"] objectForKey:@"params"]!=nil)
            {
                NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"params"] allKeys];
                NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"params"] allValues];
                NSMutableString *prams = [[NSMutableString alloc] init];
                for(int i = 0; i < [[[dic objectForKey:@"parameters"] objectForKey:@"params"]count]; i++)
                {
                    [prams appendFormat:@"%@=%@&",[keysArray objectAtIndex:i],[valuesArray objectAtIndex:i]];
                }
                NSString *removeLastChar = [prams substringWithRange:NSMakeRange(0, [prams length]-1)];
                NSString *urlString = [NSString stringWithFormat:@"%@?%@",[[dic objectForKey:@"parameters"] objectForKey:@"url"],removeLastChar];
                request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
            }
        }

        if([[dic objectForKey:@"parameters"] objectForKey:@"localFile"]!=nil)
        {
            @try
            {
                MNFile *datafile=[[MNFile alloc]init];
                docDir=[datafile dataFilePath:[[dic objectForKey:@"parameters"] objectForKey:@"localFile"]];
                [datafile deleteFile:[[dic objectForKey:@"parameters"] objectForKey:@"localFile"]];
                //[request setDownloadDestinationPath:docDir];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
        }
        if([[dic objectForKey:@"parameters"] objectForKey:@"header"]!=nil)
        {
            @try
            {
                NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"header"] allKeys];
                NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"header"] allValues];
                
                for(int i = 0; i < [[[dic objectForKey:@"parameters"] objectForKey:@"data"]count]; i++)
                {
                    [request addRequestHeader:[keysArray objectAtIndex:i] value:[valuesArray objectAtIndex:i]];
                }
                
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"cookies"]!=nil)
        {
            @try
            {
                NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"cookies"] allKeys];
                NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"cookies"] allValues];
                //Create a cookie
                NSDictionary *properties = [[[NSMutableDictionary alloc] init] autorelease];
                for(int i = 0; i < [[[dic objectForKey:@"parameters"] objectForKey:@"data"]count]; i++)
                {
                    [properties setValue:[valuesArray objectAtIndex:i] forKey:[keysArray objectAtIndex:i]];
                }
                NSHTTPCookie *cookie = [[[NSHTTPCookie alloc] initWithProperties:properties] autorelease];
                [request setUseCookiePersistence:NO];
                [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
            
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"auth"]!=nil)
        {
            @try
            {
                [request setUsername:[[[dic objectForKey:@"parameters"] objectForKey:@"auth"] objectForKey:@"username"]];
                [request setPassword:[[[dic objectForKey:@"parameters"] objectForKey:@"auth"] objectForKey:@"password"]];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"timeout"]!=nil)
        {
            @try
            {
                [request setTimeOutSeconds:[[[dic objectForKey:@"parameters"] objectForKey:@"timeout"] integerValue]];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"proxies"]!=nil)
        {
            @try
            {
                [request setProxyHost:[[[dic objectForKey:@"parameters"] objectForKey:@"proxies"] objectForKey:@"host"]];
                [request setProxyPort:[[[[dic objectForKey:@"parameters"] objectForKey:@"proxies"] objectForKey:@"port"] integerValue]];
            }
            @catch (NSException * e)
            {
                NSLog(@"Exception: %@", e);
            }
        }
        if([[dic objectForKey:@"parameters"] objectForKey:@"onSuccess"]!=nil)
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onSuccess"]];
            self.requestStarted = functionName;
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"onError"]!=nil)
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onError"]];
            self.requestError= functionName;
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"onComplete"]!=nil)
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onComplete"]];
            self.requestError = functionName;
        }
        
}

    [request setRequestMethod:[[dic objectForKey:@"parameters"] objectForKey:@"method"]];
    [request setDidStartSelector:@selector(GETStart:)];
    [request setDidFailSelector:@selector(ShowError:)];
    [request setDidFinishSelector:@selector(ShowFinish:)];
    [request setDelegate:self];
   	[request startAsynchronous];
return [self ReadJson:[[NSArray alloc]initWithObjects:[[NSString alloc]initWithFormat:@"\"Path\" : \"%@\"",@"OK"], nil]];
}
- (void)openMainViewAndDisplayJson:(NSString *)json{
    MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
    //    controller.urlString = @"http://www.google.com";
    controller.json_data = json;
    JASidePanelController *s_=[[JASidePanelController alloc]init];
    s_.sidePanelController.centerPanel=[[UINavigationController alloc] initWithRootViewController:controller];
}
-(void)ShowFinish:(ASIHTTPRequest *)theRequest
{
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"DELETE METHOD FINISH" forKey:@"deletefinish"];
    [self.bridge callHandler:self.requestFinish data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@",response);
         [self openMainViewAndDisplayJson:theRequest.responseString];
     }];
}
-(void)ShowError:(ASIHTTPRequest *)theRequest
{
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"DELETE METHOD ERROR" forKey:@"deleteerror"];
    [self.bridge callHandler:self.requestError data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@", response);
     }];
}
-(void)GETStart:(ASIHTTPRequest *)theRequest
{
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"DELETE METHOD STARTED" forKey:@"deletestarted"];
    [self.bridge callHandler:self.requestStarted data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@", response);
     }];

}
- (NSString *) ReadJson:(NSArray*)JsonArray{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    NSError *error;
    NSString *Data;
    if (JsonArray==nil) {
        result=@"Null";
        reason_to_fail=@"No data";
        Data=@"";
        NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
        return json_;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JsonArray options:0 error:&error];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!json) {
        NSLog(@"JSON error: %@", error);
        result=@"Error";
    } else {
        Data= [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    }
    NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
    return json_;
}
@end
