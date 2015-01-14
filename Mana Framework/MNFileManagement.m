//
//  MNFileManagement.m
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/22/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNFileManagement.h"
#import "MNFile.h"
@implementation MNFileManagement
- (NSString *) processRESTRequest:(NSString *)request{
    
    if ([request rangeOfString:@"mapfolder"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements1=[queryElements[2] componentsSeparatedByString:@"&"];
        NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
        NSString *httppath=queryElements2[1];
        NSString *localpath=queryElements3[1];
        NSString *rest_request = [[NSString alloc] initWithFormat:@"http://127.0.0.1:8081/localapi/mapfolder/mapfolder?localpath=%@&httppath=%@",localpath,httppath];
    /*NSURL *url = [NSURL URLWithString:request_];
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"port: %@", [url port]);
    NSLog(@"path: %@", [url path]);
    NSLog(@"path components: %@", [url pathComponents]);
    NSLog(@"parameterString: %@", [url parameterString]);
    NSLog(@"query: %@", [url query]);
    NSLog(@"fragment: %@", [url fragment]);*/
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:rest_request]];
    if(data!=nil)
    {
        //id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        //NSMutableDictionary *jsonResult = [jsonObject mutableCopy];
        NSString *json=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        return json
;
    }
    }
    
    if ([request rangeOfString:@"download"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
        NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
        NSString *url=queryElements2[1];
        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
        NSString *path=queryElements3[1];
        if ([url isEqualToString:@""]) {
            queryElements1 =nil;
            return [self ReadJson:queryElements1];
        }
        MNFile *datafile=[[MNFile alloc]init];
        [datafile downloadFile:url :path];
        //NSData *data=[datafile readFile:path];
        return [self ReadJson:queryElements1];
    }
    if ([request rangeOfString:@"rename"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
        NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
        NSString *oldpath=queryElements2[1];
        NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
        NSString *newpath=queryElements3[1];
        MNFile *datafile=[[MNFile alloc]init];
        [datafile rename:oldpath :newpath];
        return [self ReadJson:queryElements1];
    }
    if ([request rangeOfString:@"delete"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements2 = [queryElements[1] componentsSeparatedByString:@"="];
        NSArray *que=[queryElements[1] componentsSeparatedByString:@""];
        MNFile *datafile=[[MNFile alloc]init];
        [datafile deleteFile:queryElements2[1]];
        return [self ReadJson:que];
    }
    if ([request rangeOfString:@"list"].location != NSNotFound) {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements2 = [queryElements[1] componentsSeparatedByString:@"="];
        MNFile *datafile=[[MNFile alloc]init];
        return [self ReadJson:[datafile listFolder:queryElements2[1]]];
    }
    if ([request rangeOfString:@"get"].location != NSNotFound) {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
        NSArray *queryElements2 = [queryElements[1] componentsSeparatedByString:@"="];
        MNFile *datafile=[[MNFile alloc]init];
        return [self ReadJsonDictionary:[datafile get:queryElements2[1]]];
        //return [self ReadJson:queryElements2];
    }
    if ([request rangeOfString:@"create"].location != NSNotFound)
    {
        NSArray *queryElements = [request componentsSeparatedByString:@"?"];
         NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"&"];
        if ([queryElements1 count]>1) {
            NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
            NSString *body=queryElements2[1];
            NSArray *queryElements3=[queryElements1[1] componentsSeparatedByString:@"="];
            NSString *path=queryElements3[1];
            MNFile *datafile=[[MNFile alloc]init];
            [datafile createFile:body :path];
        }
        else
        {
            NSArray *queryElements2=[queryElements1[0] componentsSeparatedByString:@"="];
            NSString *path=queryElements2[1];
            MNFile *datafile=[[MNFile alloc]init];
            [datafile createFile:@"" :path];
        }
        return [self ReadJson:queryElements1];
    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
}
- (NSString *) ReadJsonDictionary:(NSMutableDictionary*)JsonArray{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    //NSError *error;
    NSString *Data;
    if (JsonArray==nil) {
        result=@"Null";
        reason_to_fail=@"No data";
        Data=@"";
        NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,Data];
        return json_;
    }
    /*NSData *jsonData = [NSJSONSerialization dataWithJSONObject:JsonArray options:0 error:&error];
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!json) {
        NSLog(@"JSON error: %@", error);
        result=@"Error";
    } else {
        Data= [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
    }*/
    NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", result,reason_to_fail,JsonArray];
    return json_;
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

@end
