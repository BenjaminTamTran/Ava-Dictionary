//
//  This class was created by Nonnus,
//  who graciously decided to share it with the CocoaHTTPServer community.
//

#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPDynamicFileResponse.h"
#import "HTTPFileResponse.h"

#import "MNDatabaseManagement.h"
#import "MNMediaManagement.h"
#import "MNApplicationManagement.h"
#import "MNSystemInfoManager.h"
#import "MNToastManagement.h"
#import "MNIconBadgeNumber.h"
#import "MNNotification.h"
#import "MNGPS.h"
#import "TKFunctionGPS.h"
#import "MNCommonFunction.h"
#import "MNFile.h"
@implementation MyHTTPConnection

/**
 * Returns whether or not the requested resource is browseable.
**/
- (BOOL)isBrowseable:(NSString *)path
{
	// Override me to provide custom configuration...
	// You can configure it for the entire server, or based on the current request
	
	return YES;
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload.html"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        int paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
		// enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }
	return [super expectsRequestBodyFromMethod:method atPath:path];
}


- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)relativePath
{
	if ([@"POST" isEqualToString:method])
	{
        /*
        if ([path isEqualToString:@"/upload.html"])
		{
			return YES;
		}
         */
		return YES;
	}
	
	return [super supportsMethod:method atPath:relativePath];
}


/**
 * Returns whether or not the server will accept POSTs.
 * That is, whether the server will accept uploaded data for the given URI.
**/
/*
- (BOOL)supportsPOST:(NSString *)path withSize:(UInt64)contentLength
{
//	NSLog(@"POST:%@", path);
	
	dataStartIndex = 0;
	multipartData = [[NSMutableArray alloc] init];
	postHeaderOK = FALSE;
	
	return YES;
}
*/

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	//HTTPLogTrace();
	
	// set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
	uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
	//HTTPLogTrace();
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}



/**
 * This method is called to get a response for a request.
 * You may return any object that adopts the HTTPResponse protocol.
 * The HTTPServer comes with two such classes: HTTPFileResponse and HTTPDataResponse.
 * HTTPFileResponse is a wrapper for an NSFileHandle object, and is the preferred way to send a file response.
 * HTTPDataResopnse is a wrapper for an NSData object, and may be used to send a custom response.
**/
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    NSString *timestamp = [[NSString alloc] initWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
//    exposeTiming(@"timing1",timestamp);
	NSLog(@"httpResponseForURI: method:%@ path:%@", method, path);
    //FRAMEWORK: DATABASE
    if ([path rangeOfString:@"/localapi/database/"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/database/" withString:@""];
        MNDatabaseManagement *database = [[MNDatabaseManagement alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[database processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: CAMERA
    if ([path rangeOfString:@"/localapi/camera/"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/camera/" withString:@""];
        MNMediaManagement *database = [[MNMediaManagement alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[database processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: MEDIA
    if ([path rangeOfString:@"/localapi/media/"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/media/" withString:@""];
        MNMediaManagement *database = [[MNMediaManagement alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[database processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: APPLICATION
    if ([path rangeOfString:@"/localapi/application/"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/application/" withString:@""];
        MNApplicationManagement *app = [[MNApplicationManagement alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[app processRESTRequest:request_to_framework withparams:nil] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: ICON BADGE NUMBER
    if([path rangeOfString:@"localapi/iconbadgenumber/"].location != NSNotFound)
    {
        MNIconBadgeNumber *controller = [[MNIconBadgeNumber alloc]init];
        NSString *json = [controller setIconBadgeNumber:path];
        return [[[HTTPDataResponse alloc] initWithData:[json dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: NOTIFICATION
    if([path rangeOfString:@"localapi/notification"].location != NSNotFound)
    {
        MNNotification *controller = [[MNNotification alloc]init];
        NSString *json  = [controller setNotificationWithPath:path];
        return [[[HTTPDataResponse alloc] initWithData:[json dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: GPS
    if([path rangeOfString:@"localapi/gps"].location != NSNotFound)
    {
        MNGPS *controller = [[MNGPS alloc]init];
        NSString *json = [controller getGPS:path];
        return [[[HTTPDataResponse alloc] initWithData:[json dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
    }
    //END FRAMEWORK
    
    //FRAMEWORK: SYSTEMINFO
    if ([path rangeOfString:@"/localapi/systeminfo/"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/systeminfo/" withString:@""];
        MNSystemInfoManager *app = [[MNSystemInfoManager alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[app processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END FRAMEWORK SYSTEMINFO
    
    //FRAMEWORK: TOAST
    if ([path rangeOfString:@"/localapi/toast"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/toast" withString:@""];
        MNToastManagement *systeminfo = [[MNToastManagement alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[systeminfo processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END TOAST
    //FRAMEWORK: MapFOLDER
    if ([path rangeOfString:@"/localapi/mapfolder"].location != NSNotFound)
    {
        NSString *request_to_framework = [path stringByReplacingOccurrencesOfString:@"/localapi/mapfolder" withString:@""];
        MNFile *mapfolder = [[MNFile alloc] init];
        return [[[HTTPDataResponse alloc] initWithData:[[mapfolder processRESTRequest:request_to_framework] dataUsingEncoding:NSUTF8StringEncoding] ] autorelease];
    }
    //END TOAST
    
	return [super httpResponseForMethod:method URI:path];
}


/**
 * This method is called to handle data read from a POST.
 * The given data is part of the POST body.
**/
//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
	// in this sample, we are not interested in parts, other then file parts.
	// check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
	NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
		// an empty form sent. we won't handle it.
		return;
	}
	NSString* uploadDirPath = [[config documentRoot] stringByAppendingPathComponent:@"upload"];
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
    }
    else {
		//HTTPLogVerbose(@"Saving file to %@", filePath);
		[[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
		storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
		[uploadedFiles addObject: [NSString stringWithFormat:@"/upload/%@", filename]];
    }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
	// here we just write the output from parser to the file.
	if( storeFile ) {
		[storeFile writeData:data];
	}
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
	// as the file part is over, we close the file.
	[storeFile closeFile];
	storeFile = nil;
}

- (void) processPreambleData:(NSData*) data
{
    // if we are interested in preamble data, we could process it here.
    
}

- (void) processEpilogueData:(NSData*) data
{
    // if we are interested in epilogue data, we could process it here.
    
}@end