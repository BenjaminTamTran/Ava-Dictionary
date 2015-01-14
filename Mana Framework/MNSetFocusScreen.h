//
//  MNSetFocusScreen.h
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MNCenterViewController.h"
#import "MNRightViewController.h"

@interface MNSetFocusScreen : NSObject

-(NSString*)navigateAndFocusWithScreenNumber:(int)_number withURL:(NSString*)_url withController:(UIViewController*)_viewController;

@end
