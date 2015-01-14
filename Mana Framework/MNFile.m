//
//  MNFile.m
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/6/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNFile.h"
#import "iKToast.h"
BOOL failed;
UIProgressView *progressIndicator;
NSArray *ArrayUrls;
ASINetworkQueue *networkQueue;
@implementation MNFile
@synthesize exc;
- (NSString *) processRESTRequest:(NSString *)request{
    
    if ([request rangeOfString:@"mapfolder"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
        //NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
        //NSString *localpath=queryElements2[1];
        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
        NSString *httppath=queryElements3[1];
        NSData *data=[self readFile:httppath];
        if (data!=nil) {
            return [self ReadJson:queryElements1];
        }
        else
        {
            queryElements1=nil;
            return [self ReadJson:queryElements1];
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

-(NSString *) dataFilePath:(NSString*)name{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [path objectAtIndex:0];
    NSString *path_ = [documentDirectory stringByAppendingPathComponent:name];
    return path_;
}
-(void) writePlist:(NSString*)name:(NSArray*)params{
    NSMutableArray *anArray=[[NSMutableArray alloc] init];
    for (int i=0; i<[params count]; i++) {
        [anArray addObject:(NSString*)params[i]];
    }
    [anArray writeToFile:name atomically:YES];
    [anArray release];
}
-(void)downloadFile:(NSString *)URL :(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        NSArray *parampath=[path componentsSeparatedByString:@"/"];
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        for (int i=0; i<[parampath count]-1; i++) {
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
        docDir=[docDir stringByAppendingPathComponent:parampath[[parampath count]-1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
            NSURL  *url = [NSURL URLWithString:URL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if (urlData)
            {
                [urlData writeToFile:docDir atomically:YES];
            }
        }
    }
}
-(void)saveimage:(UIImage *)image :(NSString *)path
{
    if ([path isEqualToString:@""]) {
         NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        int randNum = rand() % (1000 - 1) + 1;
        NSString *docDir1=[docDir stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"ScreenShot%d.png",randNum]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir1]) {
            NSData *imageData = UIImagePNGRepresentation(image);
            if (imageData)
            {
                [imageData writeToFile:docDir1 atomically:YES];
            }
        }
        else
        {
            int randNum = rand() % (1000 - 1) + 1;
            NSString *docDir1=[docDir stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"ScreenShot%d.png",randNum]];
             NSData *imageData = UIImagePNGRepresentation(image);
            if (imageData)
            {
                [imageData writeToFile:docDir1 atomically:YES];
            }
        }
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        NSArray *parampath=[path componentsSeparatedByString:@"/"];
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        for (int i=0; i<[parampath count]-1; i++) {
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
        docDir=[docDir stringByAppendingPathComponent:parampath[[parampath count]-1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
            NSData *imageData = UIImagePNGRepresentation(image);
            if (imageData)
            {
                [imageData writeToFile:docDir atomically:YES];
            }
        }
    }
    
}

-(NSMutableArray *) readPlist:(NSString*)name
{
    NSString *filePath=name;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSArray *array=[[NSArray alloc] initWithContentsOfFile:filePath];
        if ([array objectAtIndex:0] != nil)
        {   NSMutableArray *data=[[NSMutableArray alloc]init];
            [data addObject:@"1"];
            return data;
        }
        [array release];
    }
    return nil;
}
-(NSData *) readFile:(NSString *)name
{
    NSString *filePath=[self dataFilePath:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *Data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        return Data;
        [Data release];
    }
    return nil;
}
-(void)deleteFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:[self dataFilePath:path] error:NULL];
}
-(void)rename:(NSString *)oldpath :(NSString *)newpath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:oldpath]]) {
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        docDir=[docDir stringByAppendingPathComponent:oldpath];
        NSError *error;
        NSString *path = [[docDir stringByDeletingLastPathComponent] stringByAppendingPathComponent:newpath];
        [[NSFileManager defaultManager] moveItemAtPath:docDir toPath:path error:&error];
    }
}
-(NSArray *) listFolder:(NSString*)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        docDir=[docDir stringByAppendingPathComponent:path];
        NSError * error;
        NSArray * directoryContents = [[[NSArray alloc] init]autorelease];
        directoryContents =  [[NSFileManager defaultManager]contentsOfDirectoryAtPath:docDir error:&error];
        return directoryContents;
    }
    //NSArray *queryElements2 = [path componentsSeparatedByString:@"="];
    return nil;
}
-(NSMutableDictionary *) get:(NSString*)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        //return (NSDate*)[attrs objectForKey: NSFileCreationDate];
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        docDir=[docDir stringByAppendingPathComponent:path];
        NSError * error;
        NSDictionary* attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:docDir error:&error];
        NSMutableDictionary *info = [attrs mutableCopy];
        return info;
    }
    return nil;
}
-(void)createFile:(NSString *)body :(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        NSArray *parampath=[path componentsSeparatedByString:@"/"];
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        for (int i=0; i<[parampath count]-1; i++) {
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
        docDir=[docDir stringByAppendingPathComponent:parampath[[parampath count]-1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
            if ([body isEqualToString:@""]) {
                NSError *error = nil;
                NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
                [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:attr error:&error];
            }
            else
            {
                [body writeToFile:docDir atomically:YES encoding:NSStringEncodingConversionAllowLossy
                            error:nil];
            }
        }
    }
}
-(Boolean)checkDB:(NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        return true;
    }
    return false;
}
-(void)createFileData:(NSData *)body :(NSString *)path{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
        NSArray *parampath=[path componentsSeparatedByString:@"/"];
        NSString *docDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        for (int i=0; i<[parampath count]-1; i++) {
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
        docDir=[docDir stringByAppendingPathComponent:parampath[[parampath count]-1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:docDir]) {
            if (body == nil) {
                NSError *error = nil;
                NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
                [[NSFileManager defaultManager] createDirectoryAtPath:docDir withIntermediateDirectories:YES attributes:attr error:&error];
            }
            else
            {
                [body writeToFile:docDir atomically:YES];
            }
        }
    }
}

- (void)HttpComplete:(ASIHTTPRequest *)request
{
    NSLog(@"Finished index %d",exc);
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        //Your code goes in here
        [iKToast showToastWithString:[[NSString alloc]initWithFormat:@"Download Complete Index %d",exc] duration:1 withDistance:30 inPosition:iKToastPositionBottom];
    }];
    exc+=1;
}
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
    NSLog(@"Pause Index: %d",exc);
    failed = NO;
    [networkQueue cancelAllOperations];
    [networkQueue go];
    return exc;
}
-(void)resume:(int)index
{
    if (!networkQueue) {
        networkQueue = [[ASINetworkQueue alloc] init];
    }
    failed = NO;
	[networkQueue reset];
	[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(HttpComplete:)];
	[networkQueue setRequestDidFailSelector:@selector(HttpFailed:)];
	[networkQueue setDelegate:self];
	[networkQueue setMaxConcurrentOperationCount:1];
    exc=index;
    NSLog(@"Resume index: %d",exc);
	ASIHTTPRequest *request;
    for (int i=exc; i<=[ArrayUrls count]-1; i++) {
        NSString *url=ArrayUrls[i];
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        NSString *destinationPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[[NSString alloc]initWithFormat:@"%d.txt",i]];
        [request setDownloadDestinationPath:destinationPath];
        [request setTemporaryFileDownloadPath:[NSString stringWithFormat:@"%@-part",destinationPath]];
        [request setDelegate:self];
        [request setDownloadProgressDelegate:progressIndicator];
        [request setUserInfo:[NSDictionary dictionaryWithObject:[[NSString alloc]initWithFormat:@"%d.txt",i] forKey:@"name"]];
        [request setAllowResumeForFileDownloads:YES];
        [networkQueue addOperation:request];
    }
	[networkQueue go];
}
-(void)downloadQueue:(NSArray *)URLS :(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[self dataFilePath:path]]) {
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
        //docDir=[docDir stringByAppendingPathComponent:parampath[[parampath count]-1]];
        if (!networkQueue) {
            networkQueue = [[ASINetworkQueue alloc] init];
        }
        failed = NO;
        [networkQueue reset];
        [networkQueue setDownloadProgressDelegate:progressIndicator];
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
        [networkQueue go];
    }
}
@end
