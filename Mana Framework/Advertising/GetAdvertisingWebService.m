//
//  GetAdvertisingWebService.m
//  guide
//
//  Created by Tran Huu Tam on 11/20/13.
//
//

#import "GetAdvertisingWebService.h"
#import "NSDictionary+Extension.h"

@implementation GetAdvertisingWebService

+(id)getDataFromWebService:(NSString*)url withHandle:(GetAdvertisingHandler)handler{
    GetAdvertisingWebService* webService = [[GetAdvertisingWebService alloc] init];
    webService.handler = handler;
    [webService startGetRequest:url];
    return webService;
}

- (void)didReceiveData:(NSData *)data {
    NSDictionary* jsonDic = [NSJSONSerialization JSONObjectWithData:data
                                                            options:kNilOptions
                                                              error:nil];
    if (jsonDic) {
        if (self.handler) {
            NSString *code = [jsonDic objectNotNullForKey:@"code"];
            self.handler(code, jsonDic, nil);
        }
    } else {
        if (self.handler) {
            self.handler(nil, nil, nil);
        }
    }
}

- (void)didRequestFailWithError:(NSError *)error {
    if (self.handler) {
        self.handler(nil, nil, error);
    }
}
@end
