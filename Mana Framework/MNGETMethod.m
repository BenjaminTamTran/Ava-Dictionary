//
//  MNGETMethod.m
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/15/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNGETMethod.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "ASIFormDataRequest.h"
#import "MNFile.h"
#import "SSZipArchive.h"
NSString *docDir;
NSString *localfile;
@implementation MNGETMethod
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
-(NSString *)requestGETMethodWithJSON:(NSMutableDictionary *)dic
{
    ASIHTTPRequest *request;
    if([dic objectForKey:@"parameters"]!=nil)
    {
        if(![[[dic objectForKey:@"parameters"] objectForKey:@"url"]isEqualToString:@""])
        {
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[dic objectForKey:@"parameters"] objectForKey:@"url"]]];
            /*if([[dic objectForKey:@"parameters"] objectForKey:@"params"]!=nil)
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
             }*/
        }
        else
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"404",@"Error",@"URL Null"];
            return json_;
        }
        if(![[[dic objectForKey:@"parameters"] objectForKey:@"method"]isEqualToString:@""])
        {
            [request setRequestMethod:[[dic objectForKey:@"parameters"] objectForKey:@"method"]];
        }
        else
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"404",@"Error",@"Method Null"];
            return json_;
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
        /*
         if(![[[dic objectForKey:@"parameters"] objectForKey:@"localFile"]isEqualToString:@""])
         {
         @try
         {
         NSString *local=[[NSString alloc]initWithFormat:@"%@-%@",[[[dic objectForKey:@"parameters"] objectForKey:@"url"]lastPathComponent],[[NSDate date] description]];
         localfile=local;
         MNFile *datafile=[[MNFile alloc]init];
         docDir=[datafile dataFilePath:localfile];
         }
         @catch (NSException * e)
         {
         NSLog(@"Exception: %@", e);
         }
         }*/
        
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
        if(![[[dic objectForKey:@"parameters"] objectForKey:@"onSuccess"]isEqualToString:@""])
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onSuccess"]];
            self.requestStarted = functionName;
        }
        
        if(![[[dic objectForKey:@"parameters"] objectForKey:@"onError"]isEqualToString:@""])
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onError"]];
            self.requestError= functionName;
        }
        
        if(![[[dic objectForKey:@"parameters"] objectForKey:@"onComplete"]isEqualToString:@""])
        {
            NSString *functionName = [NSString stringWithFormat:@"%@",[[dic objectForKey:@"parameters"]objectForKey:@"onComplete"]];
            self.requestFinish = functionName;
        }
    }
    localfile=[self Getlocalfile:[[[dic objectForKey:@"parameters"] objectForKey:@"url"]lastPathComponent]];
    MNFile *datafile=[[MNFile alloc]init];
    docDir=[datafile dataFilePath:localfile];
    [request setDidStartSelector:@selector(GETStart:)];
    [request setDidFailSelector:@selector(ShowError:)];
    [request setDidFinishSelector:@selector(ShowFinish:)];
    [request setDelegate:self];
   	[request startAsynchronous];
    return [self ReadJson:[[NSArray alloc]initWithObjects:[[NSString alloc]initWithFormat:@"\"Path\" : \"%@\"",docDir], nil]];
}
-(NSString *)Getlocalfile:(NSString *)filename
{
    //NSDate *date = [NSDate date];
    //NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
    //[dateFormat setDateFormat:@"HH-mm-ss"];
    //NSString *dateString = [dateFormat stringFromDate:date];
    //NSString *lastcompo=[filename stringByReplacingOccurrencesOfString:@".jpg" withString:@""];
    MNFile *datafie=[[MNFile alloc]init];
    NSArray *data=[datafie listFolder:@"GetTeam"];
    NSString *local=[[NSString alloc]initWithFormat:@"GetTeam/%d-%@",[data count],filename];
    return local;
    
}
-(void)ShowFinish:(ASIHTTPRequest *)theRequest
{
    MNFile *datafile=[[MNFile alloc]init];
    NSData *file_=theRequest.responseData;
    [datafile createFileData:file_ :localfile];
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"GET METHOD FINISH" forKey:@"getfinish"];
    NSLog(@"GET Finish!");
    [self.bridge callHandler:self.requestFinish data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@",response);
     }];
}
-(void)ShowError:(ASIHTTPRequest *)theRequest
{
    MNFile *datafile=[[MNFile alloc]init];
    [datafile deleteFile:localfile];
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"GET METHOD ERROR" forKey:@"geterror"];
    [self.bridge callHandler:self.requestError data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@", response);
     }];
}
-(void)GETStart:(ASIHTTPRequest *)theRequest
{
    NSLog(@"GET Starting!");
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
-(NSString *)requestWithString
{
    ASIHTTPRequest *request;
    request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.112:5000/dictionary/data.zip"]];
    [request setRequestMethod:@"get"];
    [request setUsername:@"tam"];
    [request setPassword:@"mana"];
    localfile=[self Getlocalfile:[@"http://192.168.1.112:5000/dictionary/data.zip"lastPathComponent]];
    MNFile *datafile=[[MNFile alloc]init];
    docDir=[datafile dataFilePath:localfile];
    [request setDidStartSelector:@selector(start_:)];
    [request setDidFailSelector:@selector(error_:)];
    [request setDidFinishSelector:@selector(finish_:)];
    [request setDelegate:self];
   	[request startAsynchronous];
    return docDir;
}
-(void)finish_:(ASIHTTPRequest *)theRequest
{
    MNFile *datafile=[[MNFile alloc]init];
    NSData *file_=theRequest.responseData;
    [datafile createFileData:file_ :localfile];
    NSLog(@"GET Finish!");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"First Call", nil)
                                                    message:NSLocalizedString(@"Download Complete", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentRootPath = [documentPaths objectAtIndex:0];
    NSString *destinationPath = @"";
    NSString *sourcePath = localfile;
    [SSZipArchive unzipFileAtPath:[documentRootPath stringByAppendingPathComponent:sourcePath] toDestination:[documentRootPath stringByAppendingPathComponent:destinationPath]];
}
-(void)error_:(ASIHTTPRequest *)theRequest
{
    MNFile *datafile=[[MNFile alloc]init];
    [datafile deleteFile:localfile];
}
-(void)start_:(ASIHTTPRequest *)theRequest
{
    NSLog(@"GET Starting!");
}
@end
