//
//  MNFile.h
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/18/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface MNFile : NSObject
{
    int exc;
}
-(NSString *) dataFilePath:(NSString*)name;
-(void) writePlist:(NSString*)name:(NSArray*)params;
-(NSMutableArray *) readPlist:(NSString*)name;
-(void)downloadFile:(NSString *)URL :(NSString *)path;
-(void)createFile:(NSString*)body:(NSString *)path;
-(NSData *) readFile:(NSString*)name;
-(void) deleteFile:(NSString*)path;
-(NSArray *) listFolder:(NSString*)path;
-(NSMutableDictionary *) get:(NSString*)path;
-(void) rename:(NSString*)oldpath:(NSString*)newpath;
-(void)saveimage:(UIImage*)image:(NSString*)path;
-(void)downloadQueue:(NSArray *)URLS :(NSString *)path;
-(int)pauseQueue;
-(void)resume:(int)index;
- (NSString *) processRESTRequest:(NSString *)request;
-(void)createFileData:(NSData *)body :(NSString *)path;
-(Boolean)checkDB:(NSString*)path;
@property(nonatomic) int exc;
@end

