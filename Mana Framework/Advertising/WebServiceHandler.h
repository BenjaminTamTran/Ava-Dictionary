//
//  WebServiceHandler.h
//  guide
//
//  Created by Tran Huu Tam on 11/20/13.
//
//

#import <Foundation/Foundation.h>

@interface WebServiceHandler : NSObject
@property(nonatomic,strong) NSURLConnection*    connection;
@property(nonatomic,strong) NSMutableData*      data;
- (void)didReceiveData:(NSData *)data;
- (void)didRequestFailWithError:(NSError *)error;
- (void)cancelRequest;
- (void)startGetRequest:(NSString*) urlRequest;
- (void)startGetMultiRequestForTimeZone:(NSString*) urlRequest;
- (void)startPostRequest:(NSString*) urlRequest withBodyString:(NSString*) bodyStr;
- (void)startPostRequest:(NSString*) urlRequest withBodyData:(NSMutableData*)bodyData;
-(void)startPostRequestWithJSON:(NSString*) urlRequest withBodyData:(NSData*)bodyData;
@end
