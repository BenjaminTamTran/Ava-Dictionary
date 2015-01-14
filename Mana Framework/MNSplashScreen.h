//
//  MNSplashScreen.h
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MNSplashScreen : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *splashscreen;
-(void)saveStateSplashScreen:(NSString*)_save;
-(NSString*)httpStatusCode;
+(void)startSplashScreen:(UIViewController*)_controller;
-(void)showSplash:(UIViewController*)_controller;
-(void)saveImageURL:(NSString*)_path withTimeDelay:(NSString*)_timeDelay;
@end
