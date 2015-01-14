//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import <Foundation/Foundation.h>
#import "HTTPConnection.h"

#import "NSString+MD5.h"
#import "NSData+MD5.h"
#import <CommonCrypto/CommonDigest.h>
#import "MNConnection.h"

@class MultipartFormDataParser;

@interface MyHTTPConnection : HTTPConnection
{
	//int dataStartIndex;
	//NSMutableArray* multipartData;
	//BOOL postHeaderOK;
    
    MultipartFormDataParser*        parser;
	NSFileHandle*					storeFile;
	
	NSMutableArray*					uploadedFiles;
}

- (BOOL)isBrowseable:(NSString *)path;


//- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength;


@end