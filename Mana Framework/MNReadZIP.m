//
//  MNReadZIP.m
//  Mana Framework
//
//  Created by Toan Le on 19/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNReadZIP.h"
#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipReadStream.h"

@implementation MNReadZIP

-(NSString*)readZIPFileWithURL:(NSString*)url withFileNameToRead:(NSString*)filename
{
    NSString *content;
    ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:url mode:ZipFileModeUnzip];
	NSArray *infos= [unzipFile listFileInZipInfos];
    
	for (FileInZipInfo *info in infos)
    {
		NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size,
              info.level);
        
        if([unzipFile locateFileInZip:filename])
        {
            ZipReadStream *read= [unzipFile readCurrentFileInZip];
            NSMutableData *data= [[NSMutableData alloc] initWithLength:100000];
            int bytesRead= [read readDataWithBuffer:data];
            [read finishedReading];
            //json = [NSString stringWithUTF8String:[data bytes]];
            content = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            break;
        }
	}
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\",\"Data\":\"%@\"}",content];
    
    return json;
}
@end
