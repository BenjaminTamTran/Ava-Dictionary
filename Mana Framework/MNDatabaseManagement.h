//
//  MNDatabaseManagement.h
//  Mana portal
//
//  Created by Tam Tran on 2/5/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface MNDatabaseManagement : NSObject{

}
- (NSString *)createTableIfExits:(NSMutableDictionary*)params;
- (void) dropTableIfExit:(NSString*)name;
- (NSString *) createRecord:(NSMutableDictionary*)params;
- (NSString *) updateRecord:(NSMutableDictionary*)params;
- (NSString *) selectRecord:(NSMutableDictionary*)params;
- (NSString *) deleteRecordWithParams:(NSMutableDictionary*)params;
- (NSString *) processRESTRequest:(NSString *)request;
- (NSString *) executeSQL:(NSMutableDictionary*)params;
- (NSString *) findKeyWordForManaDict:(NSMutableDictionary*)params;

@end
