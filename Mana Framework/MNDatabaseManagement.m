//
//  MNDatabaseManagement.m
//  Mana portal
//
//  Created by Tam Tran on 2/5/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import "MNDatabaseManagement.h"
#import "MNCommonFunction.h"
#import "MNFile.h"
static sqlite3 *database = nil;
static sqlite3_stmt *statement;
NSString *tablename;
@implementation MNDatabaseManagement

- (NSString *) processRESTRequest:(NSString *)request{
    NSMutableDictionary *params = [[[NSMutableDictionary alloc] init] autorelease];
    request = [request stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *elementElements = [request componentsSeparatedByString:@"?data="];
    NSString *method_string = elementElements[0];
    NSString *table_name = [method_string substringToIndex:[method_string rangeOfString:@"/"].location];
    tablename = [[NSString alloc] initWithString:table_name];
    if ([elementElements count] > 1) {
        NSString *data_string = elementElements[1];
        NSData *data = [data_string dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        params = [jsonObject mutableCopy];
    }

    if ([request rangeOfString:@"/createtable"].location != NSNotFound)
    {
        [params setObject:table_name forKey:@"table"];
        return [self createTableIfExits:params];
    }
    if ([request rangeOfString:@"/create"].location != NSNotFound)
    {
        [params setObject:table_name forKey:@"table"];
        return [self createRecord:params];
    }
    if ([request rangeOfString:@"/update"].location != NSNotFound)
    {
        return [self updateRecord:params];
    }
    if ([request rangeOfString:@"/select"].location != NSNotFound)
    {
        [params setObject:table_name forKey:@"table"];
        return [self selectRecord:params];
    }
    if ([method_string rangeOfString:@"/delete"].location != NSNotFound)
    {
        [params setObject:table_name forKey:@"table"];
        return [self deleteRecordWithParams:params];
    }
    return @"{\"Result\":\"Fail\",\"Error\":\"No action found\"}";
}

- (NSString *) executeSQL:(NSMutableDictionary*)params{
    NSString *queryString = (NSString *)[params objectForKey:@"script"];
    NSString *dbname = (NSString *)[params objectForKey:@"dbname"];
    NSString *dataset = (NSString *)[params objectForKey:@"dataset"];
    NSString *result = @"200";
    NSString *dbstatus = @"";
    NSString *query_status = @"";
    NSString *reason_to_fail = @"";
    dataset = [dataset lowercaseString];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	NSString *dbpathStr = [documentsDir stringByAppendingPathComponent:dbname];
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbpathStr]){
        [[NSFileManager defaultManager] createFileAtPath:dbpathStr contents:nil attributes:nil];
        dbstatus = @"Create new";
    }
    const char *dbpath = [dbpathStr UTF8String];
    NSLog(@"[self getDBPath] %@", [self getDBPath]);
    if ([dataset isEqualToString:@"yes"]) {
        NSString *data = @"[";
        sqlite3_stmt    *statement;
        int count_record = 0;
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {            
            const char *select_stmt = [queryString UTF8String];
            
            if (sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL) == SQLITE_OK)
            {
                int column_number = sqlite3_column_count(statement);
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    count_record ++;
                    data = [data stringByAppendingString:@"{"];
                    for (int i = 0; i < column_number; i ++) {
                        data = [data stringByAppendingString:@"\""];
                        data = [data stringByAppendingString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_name(statement, i)]];
                        data = [data stringByAppendingString:@"\""];
                        data = [data stringByAppendingString:@":"];
                        data = [data stringByAppendingString:@"\""];
                        if ((const char *) sqlite3_column_text(statement, i) != nil) {
                            data = [data stringByAppendingString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)]];
                        }else{
                            data = [data stringByAppendingString:@""];
                        }
                        data = [data stringByAppendingString:@"\""];
                        data = [data stringByAppendingString:@","];
                    }
                    data = [data stringByAppendingString:@"},"];
                }
            }else {
                result = @"502";
                reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
            }
            sqlite3_close(database);
        }
        data = [data stringByAppendingString:@"]"];
        NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":{\"db_status\":\"%@\",\"query_status\":\"%d records selected\",\"dataset\":\"%@\"}}", result, reason_to_fail, dbstatus, count_record, data];
        return json;
    }else{
        if ([dataset isEqualToString:@"no"]) {
            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
                char *errMsg;
                const char *stmt = [queryString UTF8String];
                
                if (sqlite3_exec(database, stmt, NULL, NULL, &errMsg) != SQLITE_OK)
                {
                    result = @"502";
                    reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
                }
                sqlite3_close(database);
            } else {
                result = @"503";
                reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
            }
            NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":{\"db_status\":\"%@\",\"query_status\":\"%d records affected\",\"dataset\":\"\"}}", result, reason_to_fail, dbstatus, sqlite3_total_changes(database)];
            return json;
            return json;
        }else{
            NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"404\",\"Error\":\"Wrong param, dataset must be ’yes’ or ’no’\",\"Data\":{\"db_status\":\"%@\",\"query_status\":\"\",\"dataset\":\"\"}}", dbstatus];
            return json;
        }
        
    }
    return @"{\"Result\":\"404\",\"Error\":\"No action found\"}";
}

- (NSString *) findKeyWordForManaDict:(NSMutableDictionary*)params{
    NSString *dbname = (NSString *)[params objectForKey:@"dbname"];
    NSString *keyword = (NSString *)[params objectForKey:@"keyword"];
    NSString *queryString = [[NSString alloc] initWithFormat:@"SELECT content FROM %@ WHERE word='%@'", dbname, [keyword lowercaseString]];
    NSString *result = @"200";
    NSString *dbstatus = @"";
    NSString *query_status = @"";
    NSString *reason_to_fail = @"";
    NSString *dbnameWithDB = [[NSString alloc] initWithFormat:@"%@.db", dbname];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *filePath = [documentRootPath stringByAppendingPathComponent:dbnameWithDB];
    
//    MNFile *datafile=[[MNFile alloc]init];
//    NSString *filePath=[datafile dataFilePath:dbnameWithDB];
    const char *dbpath = [filePath UTF8String];
    NSString *data = @"";
    sqlite3_stmt    *statement;
    int count_record = 0;
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        const char *select_stmt = [queryString UTF8String];
        
        if (sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int column_number = sqlite3_column_count(statement);
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                count_record ++;
                for (int i = 0; i < column_number; i ++) {
                    if ((const char *) sqlite3_column_text(statement, i) != nil) {
                        data = [data stringByAppendingString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)]];
                    }else{
                        data = [data stringByAppendingString:@""];
                    }
                }
            }
        }else {
            result = @"502";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
        }
        sqlite3_close(database);
    }
    return data;
}


- (NSString *)createTableIfExits:(NSMutableDictionary*)params{
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    NSString *databasePath = [self getDBPath];
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *createTableSQL = [[NSString alloc] initWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, EMAIL TEXT, PHONE TEXT, IMG TEXT)", (NSString*)[params objectForKey:@"table"]];
        char *errMsg;
        const char *createtable_stmt = [createTableSQL UTF8String];
        
        if (sqlite3_exec(database, createtable_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            result = @"502";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
        }
        
        sqlite3_close(database);
        
    } else {
        result = @"503";
        reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
    }
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", result, reason_to_fail];
    executeJavaScriptOnMainThread(json);
    return json;
}

- (void) dropTableIfExit:(NSString*)name{
    NSString *databasePath = [self getDBPath];
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;
        const char *sql_stmt = "DROP TABLE IF EXISTS CONTACTS";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        
        sqlite3_close(database);
        
    } else {
        NSLog(@"Failed to open/create database");
    }
}

//DELETE
- (NSString *) deleteRecordWithParams:(NSMutableDictionary*)params{
    NSString *databasePath = [self getDBPath];
    const char *dbpath = [databasePath UTF8String];
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *conditions = @" (";
        for(NSObject *element in params){
            NSString *key = (NSString *)element;
            if (![key isEqualToString:@"table"]) {
                conditions = [conditions stringByAppendingString:key];
                conditions = [conditions stringByAppendingString:@" = "];
                conditions = [conditions stringByAppendingString:[params objectForKey:key]];
                conditions = [conditions stringByAppendingString:@" AND "];
            }
        }
        conditions = [conditions stringByAppendingString:@") "];
        conditions = [conditions stringByReplacingOccurrencesOfString:@" AND )" withString:@")"];
        NSString *deleteSQL = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@", (NSString*)[params objectForKey:@"table"], conditions];
        char *errMsg;
        const char *delete_stmt = [deleteSQL UTF8String];
        
        if (sqlite3_exec(database, delete_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            result = @"Fail";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
            NSLog(@"Failed to delete record");
        }
        
        sqlite3_close(database);
        
    } else {
        NSLog(@"Failed to open/create database");
    }
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", result, reason_to_fail];
    executeJavaScriptOnMainThread(json);
    return json;
}

//CREATE
- (NSString *) createRecord:(NSMutableDictionary *)params{
    const char *dbpath = [[self getDBPath] UTF8String];
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *key_input = @"(";
        NSString *value_input = @"(";
        for(NSObject *element in params){
            NSString *key = (NSString *)element;
            if (![key isEqualToString:@"table"]) {
                key_input = [key_input stringByAppendingString:key];
                key_input = [key_input stringByAppendingString:@", "];
                value_input = [value_input stringByAppendingString:[params objectForKey:key]];
                value_input = [value_input stringByAppendingString:@", "];
            }
        }
        key_input = [key_input stringByAppendingString:@")"];
        key_input = [key_input stringByReplacingOccurrencesOfString:@", )" withString:@")"];
        value_input = [value_input stringByAppendingString:@")"];
        value_input = [value_input stringByReplacingOccurrencesOfString:@", )" withString:@")"];
        NSString *createSQL = [NSString stringWithFormat: @"INSERT INTO %@ %@ VALUES %@", (NSString*)[params objectForKey:@"table"], (NSString*)key_input, value_input];
        const char *create_stmt = [createSQL UTF8String];
        
        sqlite3_prepare_v2(database, create_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            result = @"502";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", result, reason_to_fail];
    executeJavaScriptOnMainThread(json);
    return json;
}

//UPDATE
- (NSString *) updateRecord:(NSMutableDictionary *)params{
    const char *dbpath = [[self getDBPath] UTF8String];
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *conditions = @" (";
        NSString *update_con = @"";
        BOOL where = false;
        for(NSObject *element in params){
            for(NSObject *ele in element){
                if (!where) {
                    NSString *key = (NSString *)ele;
                    conditions = [conditions stringByAppendingString:key];
                    conditions = [conditions stringByAppendingString:@" = "];
                    conditions = [conditions stringByAppendingString:[element objectForKey:key]];
                    conditions = [conditions stringByAppendingString:@" AND "];
                }else{
                    NSString *key = (NSString *)ele;
                    update_con = [update_con stringByAppendingString:key];
                    update_con = [update_con stringByAppendingString:@" = "];
                    update_con = [update_con stringByAppendingString:[element objectForKey:key]];
                    update_con = [update_con stringByAppendingString:@" AND "];
                }
            }
            where = true;
        }
        conditions = [conditions stringByAppendingString:@") "];
        conditions = [conditions stringByReplacingOccurrencesOfString:@" AND )" withString:@")"];
        update_con = [update_con stringByAppendingString:@") "];
        update_con = [update_con stringByReplacingOccurrencesOfString:@" AND )" withString:@""];
        NSString *updateSQL = [NSString stringWithFormat: @"UPDATE %@ SET %@ WHERE %@", tablename, update_con, conditions];
        const char *update_stmt = [updateSQL UTF8String];
        
        sqlite3_prepare_v2(database, update_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) != SQLITE_DONE)
        {
            result = @"502";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\"}", result, reason_to_fail];
    executeJavaScriptOnMainThread(json);
    return json;
}

//SELECT
- (NSString *) selectRecord:(NSMutableDictionary*)params
{
    const char *dbpath = [[self getDBPath] UTF8String];
    NSString *result = @"200";
    NSString *reason_to_fail = @"";
    NSString *data = @"[";
    sqlite3_stmt    *statement;
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *conditions = @" (";
        for(NSObject *element in params){
            NSString *key = (NSString *)element;
            if (![key isEqualToString:@"table"]) {
                conditions = [conditions stringByAppendingString:key];
                conditions = [conditions stringByAppendingString:@" = "];
                conditions = [conditions stringByAppendingString:[params objectForKey:key]];
                conditions = [conditions stringByAppendingString:@" AND "];
            }
        }
        conditions = [conditions stringByAppendingString:@") "];
        conditions = [conditions stringByReplacingOccurrencesOfString:@" AND )" withString:@")"];
        NSString *selectSQL = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE %@", (NSString*)[params objectForKey:@"table"], conditions];
        
        const char *select_stmt = [selectSQL UTF8String];
        
        if (sqlite3_prepare_v2(database, select_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            int column_number = sqlite3_column_count(statement);
            while(sqlite3_step(statement) == SQLITE_ROW)
            {
                data = [data stringByAppendingString:@"{"];
                for (int i = 0; i < column_number; i ++) {
                    data = [data stringByAppendingString:@"\""];
                    data = [data stringByAppendingString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_name(statement, i)]];
                    data = [data stringByAppendingString:@"\""];
                    data = [data stringByAppendingString:@":"];
                    data = [data stringByAppendingString:@"\""];
                    if ((const char *) sqlite3_column_text(statement, i) != nil) {
                        data = [data stringByAppendingString:[[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, i)]];
                    }else{
                        data = [data stringByAppendingString:@""];
                    }
                    data = [data stringByAppendingString:@"\""];
                    data = [data stringByAppendingString:@","];
                }
                data = [data stringByAppendingString:@"},"];
            } 
        }else {
            result = @"502";
            reason_to_fail = [[NSString alloc] initWithFormat:@"%s", sqlite3_errmsg(database)];
        }
        sqlite3_close(database);
    }
    data = [data stringByAppendingString:@"]"];
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":%@}", result, reason_to_fail, data];
    executeJavaScriptOnMainThread(json);
    return json;
}

- (NSString *) getDBPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"SQL.db"];
}



@end
