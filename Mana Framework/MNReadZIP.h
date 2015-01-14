//
//  MNReadZIP.h
//  Mana Framework
//
//  Created by Toan Le on 19/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNReadZIP : NSObject

-(NSString*)readZIPFileWithURL:(NSString*)url withFileNameToRead:(NSString*)filename;

@end
