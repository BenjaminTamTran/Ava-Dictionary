//
//  MNGetFocusScreen.m
//  Mana Framework
//
//  Created by Toan Le on 04/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNGetFocusScreen.h"

@implementation MNGetFocusScreen

-(void)stateScreenWithScreenNumber:(NSString*)_number
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_number forKey:@"screennumber"];
}

-(NSString*)getScreenNumber
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\",\"Data\":\"%@\"}",[defaults objectForKey:@"screennumber"]];
}
@end
