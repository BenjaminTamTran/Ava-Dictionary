//
//  MNSplashScreen.m
//  Mana Framework
//
//  Created by Toan Le on 01/03/2013.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNSplashScreen.h"

@interface MNSplashScreen ()

@end

@implementation MNSplashScreen

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

-(void)saveImageURL:(NSString *)_path withTimeDelay:(NSString *)_timeDelay
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(_timeDelay.length == 0)
    {
        [defaults setObject:@"1" forKey:@"timedelay"];
    }
    else
    {
        if([self textFieldValidation:_timeDelay] == true)
        {
            [defaults setObject:_timeDelay forKey:@"timedelay"];
        }
        else
        {
            [defaults setObject:@"1" forKey:@"timedelay"];
        }
    }
    [self performSelectorInBackground:@selector(saveImageLocal:) withObject:_path];
}

-(BOOL) textFieldValidation:(NSString *)checkString
{
    NSString *stricterFilterString = @"[0-9]+";
    NSString *regEx =  stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
    return [emailTest evaluateWithObject:checkString];
}

-(void)saveImageLocal:(NSString *)_path
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:_path]];
    if(data!=nil)
    {
        [defaults setObject:data forKey:@"splashscreenImage"];
    }
}

+(void)startSplashScreen:(UIViewController*)_controller
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"splashscreen"]!=nil)
    {
        if([[defaults objectForKey:@"splashscreen"]isEqualToString:@"ON"])
        {
            MNSplashScreen *controller = [[MNSplashScreen alloc]initWithNibName:@"MNSplashScreen" bundle:nil];
            [controller showSplash:_controller];
        }
    }
}

- (void)showSplash:(UIViewController*)_controller
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"splashscreenImage"]!=nil)
    {
        UIImage *image = [UIImage imageWithData:[defaults objectForKey:@"splashscreenImage"]];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = self.view.bounds;
        [self.view addSubview:imageView];
    }
    else
    {
        UIImage *image = [UIImage imageNamed:@"splashScreen.jpg"];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = self.view.bounds;
        [self.view addSubview:imageView];
    }
    [_controller presentModalViewController:self animated:NO];
    
    [self performSelector:@selector(hideSplash:) withObject:_controller afterDelay:[[defaults objectForKey:@"timedelay"] floatValue]];
}

-(void) hideSplash:(UIViewController*)_controller
{
    [_controller dismissModalViewControllerAnimated:YES];
}

-(void)saveStateSplashScreen:(NSString *)_save
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:@"timedelay"] == nil)
    {
        [defaults setObject:@"1" forKey:@"timedelay"];
    }
    if([_save isEqualToString:@"on"])
    {
        [defaults setObject:@"ON" forKey:@"splashscreen"];
    }
    else
    {
        [defaults setObject:@"OFF" forKey:@"splashscreen"];
    }
   
}
-(NSString*)httpStatusCode
{
    NSString *json = [[NSString alloc] initWithFormat:@"{\"Result\":\"200\",\"Error\":\"OK\"}"];
    return json;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_splashscreen release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSplashscreen:nil];
    [super viewDidUnload];
}
@end
