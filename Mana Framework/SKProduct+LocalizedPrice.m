//
//  SKProduct+LocalizedPrice.m
//  AVA Dict
//
//  Created by Tran Huu Tam on 5/10/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "SKProduct+LocalizedPrice.h"

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end
