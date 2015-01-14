//
//  MNSystemInfoManager.h
//  Mana portal
//
//  Created by Tuan Truong Anh on 2/18/13.
//  Copyright (c) 2013 Mana. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SystemServices.h"
@interface MNSystemInfoManager : NSObject
{
    
}
- (NSString *) processRESTRequest:(NSString *)request;
-(NSMutableDictionary*)request;
-(NSArray*)key;
@end
