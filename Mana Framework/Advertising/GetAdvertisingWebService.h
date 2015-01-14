//
//  GetAdvertisingWebService.h
//  guide
//
//  Created by Tran Huu Tam on 11/20/13.
//
//

#import "WebServiceHandler.h"
typedef void (^GetAdvertisingHandler) (NSString *code, NSDictionary *data, NSError *error);
@interface GetAdvertisingWebService : WebServiceHandler
@property (nonatomic, strong) GetAdvertisingHandler handler;
+(id)getDataFromWebService:(NSString*)url withHandle:(GetAdvertisingHandler)handler;
@end