//
//  NSDictionary+Extension.m
//  guide
//
//  Created by Tran Huu Tam on 11/20/13.
//
//

#import "NSDictionary+Extension.h"

@implementation NSDictionary (Extension)
-(id)objectNotNullForKey:(id)key{
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    else{
        return object;
    }
}
@end
