//
//  MNDownloadQueue.m
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/1/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNDownloadQueue.h"
#import "iKToast.h"
#import "MNFile.h"
BOOL failed;
UIProgressView *progressIndicator;
NSArray *ArrayUrls;
NSString *foldername;
ASINetworkQueue *networkQueue;
@implementation MNDownloadQueue
@synthesize exc;
- (NSString *) processRESTRequest:(NSString *)request{
    if ([request rangeOfString:@"set"].location != NSNotFound)
    {
        if ([[request componentsSeparatedByString:@"="][1] isEqualToString:@""]) {
            
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",@""];
            return json_;
        }
        else
        {
            NSArray *queryElements = [request componentsSeparatedByString:@"?"];
            NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
            NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
            NSString *Listurls=queryElements2[1];
            NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
            NSString *path=queryElements3[1];
            NSArray *urls=[Listurls componentsSeparatedByString:@","];
            [self downloadQueue:urls :path];
            return [self ReadJson:queryElements1];
        }
    }
    if ([request rangeOfString:@"get"].location != NSNotFound)
    {
        
    }
    if ([request rangeOfString:@"pause"].location != NSNotFound)
    {
        NSArray *check=[self readPlist:@"checkdownload"];
        if ([check[0] intValue]==1 || [check[0] intValue]== 2) {
            if ([[request componentsSeparatedByString:@"="][1] isEqualToString:@""]) {
                [self writePlist:@"checkdownload":[[NSArray alloc] initWithObjects:[[NSString alloc]initWithFormat:@"%d",3],nil]];
                exc=[self pauseQueue];
                NSString *data=[[NSString alloc]initWithFormat:@"Pause Index: %d",exc];
                NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",data];
                return json_;
            }
        }
        else if ([check[0] intValue]==3)
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"404",@"Download queue paused"];
            return json_;
        }
        else
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"404",@"No SetDownload Queue"];
            return json_;
        }
    }
    if ([request rangeOfString:@"resume"].location != NSNotFound)
    {
        NSArray *check=[self readPlist:@"checkdownload"];
        if ([check[0] intValue]==3) {
            if ([[request componentsSeparatedByString:@"="][1] isEqualToString:@""]) {
                [self writePlist:@"checkdownload":[[NSArray alloc] initWithObjects:[[NSString alloc]initWithFormat:@"%d",2],nil]];
                exc=[self resume:exc];
                NSString *data=[[NSString alloc]initWithFormat:@"Resume index: %d",exc];
                NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",data];
                return json_;
            }
        }
        else if ([check[0] intValue]==2)
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"404",@"Download queue resume"];
            return json_;
        }
        else if ([check[0] intValue]==1)
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"404",@"Downloading Queue"];
            return json_;
        }
        else
        {
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", @"404",@"No SetDownload Queue"];
            return json_;
        }
    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
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
- (void)HttpComplete:(ASIHTTPRequest *)request
{
    NSLog(@"Finished index %d",exc);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        [iKToast showToastWithString:[[NSString alloc]initWithFormat:@"Download Complete Index %d",exc] duration:1 withDistance:30 inPosition:iKToastPositionBottom];
    }];
    exc+=1;
    [self writePlist:@"team":[[NSArray alloc] initWithObjects:[[NSString alloc]initWithFormat:@"%d",exc],foldername, nil]];
    NSArray *data=[self readPlist:@"team"];
    NSArray *data1=[self readPlist:@"teamArray"];
    if ([data[0] intValue]==[data1 count]) {
        [self deleteFile:@"team.plist"];
        [self deleteFile:@"teamArray.plist"];
        [self deleteFile:@"checkdownload.plist"];
    }
}
/*
 - (void)QueueComplete:(ASIHTTPRequest *)request
 {
 NSLog(@"Finished Queue");
 [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
 //Your code goes in here
 [iKToast showToastWithString:[[NSString alloc]initWithFormat:@"Download Complete"] duration:2 withDistance:30 inPosition:iKToastPositionTop];
 }];
 MNFile *datafile=[[MNFile alloc]init];
 [datafile deleteFile:foldername];
 }*/
- (void)HttpFailed:(ASIHTTPRequest *)request
{
	if (!failed) {
		if ([[request error] domain] != NetworkRequestErrorDomain || [[request error] code] != ASIRequestCancelledErrorType) {
			UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Download failed" message:@"Failed to download images" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alertView show];
		}
		failed = YES;
	}
}

-(int)pauseQueue
{
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    NSArray *data=[self readPlist:@"team"];
    NSLog(@"Pause Index: %@",data[0]);
    failed = NO;
    [networkQueue cancelAllOperations];
    [networkQueue go];
    return [data[0] intValue];
}
-(int)resume:(int)index
{
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    failed = NO;
	[networkQueue reset];
	[networkQueue setDownloadProgressDelegate:progressIndicator];
    //[networkQueue setQueueDidFinishSelector:@selector(QueueComplete:)];
	[networkQueue setRequestDidFinishSelector:@selector(HttpComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(HttpFailed:)];
	[networkQueue setDelegate:self];
	[networkQueue setMaxConcurrentOperationCount:1];
    NSArray *data=[self readPlist:@"team"];
    exc=[data[0] intValue];
    foldername=data[1];
    NSLog(@"Resume index: %d",exc);
	ASIHTTPRequest *request;
    ArrayUrls=[self readPlist:@"teamArray"];
    
    for (int i=exc; i<=[ArrayUrls count]-1; i++) {
        NSString *url=ArrayUrls[i];
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        NSString *destinationPath = [foldername stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"%d.txt",i]];
        [request setDownloadDestinationPath:destinationPath];
        [request setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@-part",destinationPath]];
        [request setDelegate:self];
        [request setDownloadProgressDelegate:progressIndicator];
        [request setUserInfo:[NSDictionary dictionaryWithObject:[[NSString alloc]initWithFormat:@"%d.txt",i] forKey:@"name"]];
        [request setAllowResumeForFileDownloads:YES];
        [networkQueue addOperation:request];
    }
    [self writePlist:@"teamArray" :ArrayUrls];
	[networkQueue go];
    return [data[0] intValue];
}
-(void)downloadQueue:(NSArray *)URLS :(NSString *)path
{
    //if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
    NSArray *parampath=[path componentsSeparatedByString:@"/"];
    NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    for (int i=0; i<[parampath count]; i++) {
        BOOL isDirectory;
        NSString *FolderDir = [docDir stringByAppendingPathComponent:parampath[i]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:FolderDir isDirectory:&isDirectory] || !isDirectory) {
            NSError *error = nil;
            NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
            [[NSFileManager defaultManager] createDirectoryAtPath:FolderDir withIntermediateDirectories:YES attributes:attr error:&error];
            if (error)
                NSLog(@"Error creating directory path: %@", [error localizedDescription]);
            docDir=[docDir stringByAppendingPathComponent:parampath[i]];
        }
        else
        {
            docDir=[docDir stringByAppendingPathComponent:parampath[i]];
        }
    }
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    failed = NO;
    [networkQueue reset];
    [networkQueue setDownloadProgressDelegate:progressIndicator];
    //[networkQueue setQueueDidFinishSelector:@selector(QueueComplete:)];
    [networkQueue setRequestDidFinishSelector:@selector(HttpComplete:)];
    [networkQueue setRequestDidFailSelector:@selector(HttpFailed:)];
    [networkQueue setShowAccurateProgress:failed];
    [networkQueue setDelegate:self];
    [networkQueue setMaxConcurrentOperationCount:1];
    exc=0;
    for (int i=0; i<[URLS count]; i++) {
        NSString *path_;
        NSString *filename=[[NSString alloc] initWithFormat:@"%d.txt",i];
        path_=[docDir stringByAppendingPathComponent:filename];
        foldername=docDir;
        if (![[NSFileManager defaultManager] fileExistsAtPath:path_]) {
            ASIHTTPRequest *request;
            request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLS[i]]];
            [request setDownloadDestinationPath:path_];
            [request setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@-part",path_]];
            [request setDelegate:self];
            [request setDownloadProgressDelegate:progressIndicator];
            [request setUserInfo:[NSDictionary dictionaryWithObject:[[NSString alloc]initWithFormat:@"%d.txt",i] forKey:@"name"]];
            [request setAllowResumeForFileDownloads:YES];
            [networkQueue addOperation:request];
        }
    }
    ArrayUrls=URLS;
    [self writePlist:@"team":[[NSArray alloc] initWithObjects:[[NSString alloc]initWithFormat:@"%d",0],foldername, nil]];
    [self writePlist:@"checkdownload":[[NSArray alloc] initWithObjects:[[NSString alloc]initWithFormat:@"%d",1],nil]];
    [self writePlist:@"teamArray" :ArrayUrls];
    [networkQueue go];
    //}
}
-(NSArray *)readPlist:(NSString*)filename
{
    NSString *docDir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"%@.plist",filename]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
        NSArray *array=[[NSArray alloc] initWithContentsOfFile:docDir];
        return array;
    }
    return nil;
}

-(void)writePlist:(NSString*)filename:(NSArray*)params{
    NSString *docDir = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"%@.plist",filename]];
    NSMutableArray *anArray=[[NSMutableArray alloc] init];
    for (int i=0; i<[params count]; i++) {
        [anArray addObject:(NSString*)params[i]];
    }
    [anArray writeToFile:docDir atomically:YES];
    [anArray release];
}
-(NSString *) dataFilePath:(NSString*)name{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *path_ = [documentDirectory stringByAppendingPathComponent:name];
    return path_;
}
-(void)deleteFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self dataFilePath:path] error:NULL];
}
@end
