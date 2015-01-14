//
//  MNDownloadQueue.h
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/1/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface MNDownloadQueue : NSObject
{
    int exc;
}
- (NSString *) processRESTRequest:(NSString *)request;
@property(nonatomic) int exc;
@end
