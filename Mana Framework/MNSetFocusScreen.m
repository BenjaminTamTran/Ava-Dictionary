//
//  MNSetFocusScreen.m
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNSetFocusScreen.h"

@implementation MNSetFocusScreen

-(NSString*)navigateAndFocusWithScreenNumber:(int)_number withURL:(NSString*)_url withController:(UIViewController*)_viewController
{
    if(_number == 5)
    {
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"navigateFocusCenter" object:nil userInfo:_dic];
        MNCenterViewController *controller = [[MNCenterViewController alloc]initWithNibName:@"MNCenterViewController" bundle:nil];
        controller.urlString = _url;
        _viewController.sidePanelController.centerPanel = [[UINavigationController alloc] initWithRootViewController:controller];
        return [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\"}"];
    }
    if(_number == 6)
    {
        MNRightViewController *controller = [[MNRightViewController alloc]initWithNibName:@"MNRightViewController" bundle:nil];
        controller.urlString = _url;
        _viewController.sidePanelController.rightPanel = controller;
        [_viewController.sidePanelController showRightPanel:YES];
        return [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\"}"];
    }
    return [[NSString alloc] initWithFormat:@"{\"Result\":\"450\",\"Error\":\"Wrong Parameters\"}"];
}

@end
