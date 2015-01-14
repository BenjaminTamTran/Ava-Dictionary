//
//  SKProduct+LocalizedPrice.h
//  AVA Dict
//
//  Created by Tran Huu Tam on 5/10/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end
