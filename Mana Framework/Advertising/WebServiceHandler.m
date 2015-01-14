//
//  WebServiceHandler.m
//  guide
//
//  Created by Tran Huu Tam on 11/20/13.
//
//

#import "WebServiceHandler.h"
#define kBoundary @"---------------------------14737809831466499882746641449"
@implementation WebServiceHandler
@synthesize connection;
@synthesize data;
-(id)init{
    if(self = [super init]){
        self.data = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)cancelRequest{
    [self.connection cancel];
}

#pragma mark - Overriden methods
/*
 Below 2 methods have to be overriden by subclasses
 Handle when finish receive data or connection have a problem
 */
- (void)didReceiveData:(NSData *)data {
    [NSException raise:NSInternalInconsistencyException format:@"Subclass must override %@ method", NSStringFromSelector(_cmd)];
}

- (void)didRequestFailWithError:(NSError *)error{
    [NSException raise:NSInternalInconsistencyException format:@"Subclass must override %@ method", NSStringFromSelector(_cmd)];
}

#pragma mark - Call ws methods

#pragma mark - Post/Get Method

-(void)startGetRequest:(NSString*) urlRequest
{
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequest]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:30];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

-(void)startGetMultiRequestForTimeZone:(NSString*) urlRequest
{
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlRequest]
											 cachePolicy:NSURLRequestUseProtocolCachePolicy
										 timeoutInterval:30];
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    
    [mutableRequest addValue:localDateString forHTTPHeaderField:@"Accept-Datetime"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    NSLog(@"%@", [request allHTTPHeaderFields]);
//    NSLog(@"%@", [mutableRequest allHTTPHeaderFields]);
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}
-(void)startPostRequest:(NSString*) urlRequest withBodyString:(NSString*) bodyStr
{
    NSData *postData = [bodyStr dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlRequest]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:30];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    
}

-(void)startPostRequest:(NSString*) urlRequest withBodyData:(NSMutableData*)bodyData{
    NSURL *url = [NSURL URLWithString:urlRequest];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",kBoundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    // set request body
    [request setHTTPBody:bodyData];
    [request addValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}
//Tam Tran: on 6/20/13, for task ANOMO-5901
//method to post data via JSON
-(void)startPostRequestWithJSON:(NSString*) urlRequest withBodyData:(NSData*)bodyData{
    NSURL *url = [NSURL URLWithString:urlRequest];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPShouldHandleCookies:NO];
    [request setTimeoutInterval:30];
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // set request body
    [request setHTTPBody:bodyData];
    [request addValue:[NSString stringWithFormat:@"%d", [bodyData length]] forHTTPHeaderField:@"Content-Length"];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - Connection delegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)receivedData {
    [data appendData:receivedData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [self didReceiveData:data];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Network failed with error: %@", [error description]);
    [self didRequestFailWithError:error];
}
@end

