//
//  MNPUTMethod.m
//  Mana Framework
//
//  Created by Toan Le on 15/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNPUTMethod.h"

@implementation MNPUTMethod
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

-(NSString*)requestPutMethodWithJSON:(NSMutableDictionary *)dic
{
    ASIHTTPRequest *request; 
    //[request appendPostData:[@"This is my data" dataUsingEncoding:NSUTF8StringEncoding]];
    // Default becomes POST when you use appendPostData: / appendPostDataFromFile: / setPostBody:

    if([dic objectForKey:@"parameters"]!=nil)
    {
        if([[dic objectForKey:@"parameters"] objectForKey:@"url"]!=nil)
        {
            //request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[dic objectForKey:@"parameters"] objectForKey:@"url"]]];
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://allseeing-i.com/"]];
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"params"]!=nil)
        {
            /*
            NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"params"] allKeys];
            NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"params"] allValues];
            
            for(int i = 0; i < [[[dic objectForKey:@"parameters"] objectForKey:@"params"]count]; i++)
            {
                //[request app
                //[request setPostValue:[valuesArray objectAtIndex:i] forKey:[keysArray objectAtIndex:i]];
            }
            */
            
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"data"]!=nil)
        {
            //NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"data"] allKeys];
            NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"data"] allValues];
            
            for(int i = 0; i < [[[dic objectForKey:@"parameters"] objectForKey:@"data"]count]; i++)
            {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[valuesArray objectAtIndex:i]]];
                [request appendPostData:data];
            }
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"headers"]!=nil)
        {
            @try
            {
                NSArray *keysArray = [[[dic objectForKey:@"parameters"] objectForKey:@"headers"] allKeys];
                NSArray *valuesArray = [[[dic objectForKey:@"parameters"] objectForKey:@"headers"] allValues];
                
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
            //FULL CODE
            /*
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
             */
            //Create a cookie
            NSDictionary *properties = [[[NSMutableDictionary alloc] init] autorelease];
            [properties setValue:@"Test Value" forKey:NSHTTPCookieValue];
            [properties setValue:@"ASIHTTPRequestTestCookie" forKey:NSHTTPCookieName];
            [properties setValue:@".allseeing-i.com" forKey:NSHTTPCookieDomain];
            [properties setValue:[NSDate dateWithTimeIntervalSinceNow:60*60] forKey:NSHTTPCookieExpires];
            [properties setValue:@"/asi-http-request/tests" forKey:NSHTTPCookiePath];
            NSHTTPCookie *cookie = [[[NSHTTPCookie alloc] initWithProperties:properties] autorelease];
            [request setUseCookiePersistence:NO];
            [request setRequestCookies:[NSMutableArray arrayWithObject:cookie]];
            
        }
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"files"]!=nil)
        {
            [request appendPostDataFromFile:@"/Users/toanle/Documents/TestAPIASIHTTP/TestAPIASIHTTP/menu.json"];
            //[request setFile:@"/Users/toanle/Documents/TestAPIASIHTTP/TestAPIASIHTTP/menu.json" forKey:@"menu"];
            /*
             NSData *data = [[[NSMutableData alloc] initWithLength:256*1024] autorelease];
             NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"file"];
             [data writeToFile:path atomically:NO];
             
             //Add the file 8 times to the request, for a total request size around 2MB
             int i;
             for (i=0; i<8; i++) {
             [request setFile:path forKey:[NSString stringWithFormat:@"file-%i",i]];
             }
             */
            /*
             NSArray *valuesArray = [[dic objectForKey:@"parameters"] objectForKey:@"files"];
             for(int i = 0; i < valuesArray.count; i++)
             {
             [request setFile:[valuesArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"File%d",i]];
             }
             */
            
            /*
            NSArray* documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString* documentRootPath = [documentPaths objectAtIndex:0];
            NSArray *valuesArray = [[dic objectForKey:@"parameters"] objectForKey:@"files"];
            for(int i = 0; i < valuesArray.count; i++)
            {
                NSString *path = [NSString stringWithFormat:@"%@%@",documentRootPath,[valuesArray objectAtIndex:i]];
                [request appendPostDataFromFile:path];
            }
            */ 
            
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
        
        if([[dic objectForKey:@"parameters"] objectForKey:@"proxy"]!=nil)
        {
            @try
            {
                [request setProxyHost:[[[dic objectForKey:@"parameters"] objectForKey:@"proxy"] objectForKey:@"host"]];
                [request setProxyPort:[[[[dic objectForKey:@"parameters"] objectForKey:@"proxy"] objectForKey:@"port"] integerValue]];
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
            self.requestFinish = functionName;
        }
        
    }
    
    [request setRequestMethod:@"PUT"];
    [request setShouldContinueWhenAppEntersBackground:YES];
    [request setDelegate:self];
    [request setDidStartSelector:@selector(uploadStarted:)];
    [request setDidFailSelector:@selector(uploadFailed:)];
    [request setDidFinishSelector:@selector(uploadFinished:)];
    
   	[request startAsynchronous];
    
    return [self httpStatusCode:@"200" withErrorMessage:@"OK"];
}

-(void)uploadStarted:(ASIHTTPRequest *)theRequest
{
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"PUT METHOD STARTED" forKey:@"putstarted"];
    [self.bridge callHandler:self.requestStarted data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@", response);
     }];
}

-(void)uploadFailed:(ASIHTTPRequest *)theRequest
{
	//[_resultView setText:[NSString stringWithFormat:@"Request failed:\r\n%@",[[theRequest error] localizedDescription]]];
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"PUT METHOD ERROR" forKey:@"puterror"];
    [self.bridge callHandler:self.requestError data:data responseCallback:^(id response)
     {
         NSLog(@"responded: %@",response);
     }];
}

-(void)uploadFinished:(ASIHTTPRequest *)theRequest
{
	//[_resultView setText:[NSString stringWithFormat:@"Finished uploading %llu bytes of data",[theRequest postLength]]];
    NSLog(@"RESPOND:%@",theRequest.responseString);
    NSLog(@"Finished uploading %llu bytes of data",[theRequest postLength]);
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    if (notification)
    {
		[notification setFireDate:[NSDate date]];
		[notification setTimeZone:[NSTimeZone defaultTimeZone]];
		[notification setRepeatInterval:0];
		[notification setSoundName:@"alarmsound.caf"];
		[notification setAlertBody:@"Boom!\r\n\r\nUpload is finished!"];
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
    NSDictionary* data = [NSDictionary dictionaryWithObject:@"PUT METHOD COMPLETE" forKey:@"putcomplete"];
    [self.bridge callHandler:self.requestFinish data:data responseCallback:^(id response)
     {
          NSLog(@"responded:%@", response);
     }];
}

-(NSString*)httpStatusCode:(NSString*)code withErrorMessage:(NSString*)_mess
{
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", code, _mess];
    return json;
}


@end
