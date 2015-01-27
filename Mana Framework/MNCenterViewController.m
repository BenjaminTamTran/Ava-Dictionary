//
//  MNCenterViewController.m
//  ManaPortal 2
//
//  Created by Toan Le on 04/02/2013.
//  Copyright (c) 2013 Toan Le. All rights reserved.
//

#import "MNCenterViewController.h"
#import "MNAppDelegate.h"
#import "MNFile.h"
#import "MNGETMethod.h"
#import "SSZipArchive.h"
#import "MNSystemInfoManager.h"
#import "MNGPS.h"
#import "iKToast.h"
#import "AdvertisingView.h"
#import "GetAdvertisingWebService.h"
#import "NSDictionary+Extension.h"
#import "GADBannerView.h"
#import "GADRequest.h"
NSString *home_url = @"http://127.0.0.1:8080/cache/http://a.p.mana.vn/main2/feature_v2";

@interface MNCenterViewController ()<AdvertisingViewDelegate>{
    
}

@end

@implementation MNCenterViewController
@synthesize  webbridge = _webbridge;
@synthesize urlString;;
@synthesize json_data;
@synthesize menu_;@synthesize Source_anh_viet,Source_viet_anh;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        self.title = @"AVA Từ điển";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bannerView.adUnitID = @"a152e14e8951ef3";
    self.bannerView.rootViewController = self;
    
    GADRequest *request = [GADRequest request];
    // Enable test ads on simulators.
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.bannerView loadRequest:request];

    self.sidePanelController.leftFixedWidth = self.view.bounds.size.width - 44;
    self.sidePanelController.rightFixedWidth = self.view.bounds.size.width - 30;
    
//    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    self.webView.delegate = self;
//    self.webView.scrollView.bounces = NO;

    [WebViewJavascriptBridge enableLogging];
    
    _webbridge = [WebViewJavascriptBridge bridgeForWebView:self.webView handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSLog(@"ObjC received message from JS: %@", data);
        NSMutableDictionary *dicJson;
        dicJson = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        NSString *api = (NSString *)[dicJson objectForKey:@"api"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([api isEqualToString:@"history"]) {
            NSString *history = (NSString *)[defaults objectForKey:@"history"];
            if (history != nil) {
                responseCallback(history);
            }
        }
        if ([api isEqualToString:@"bookmarks"]) {
            NSString *bookmarks = (NSString *)[defaults objectForKey:@"bookmarks"];
            if (bookmarks != nil) {
                responseCallback(bookmarks);
            }
        }
        if ([api isEqualToString:@"set_css"]) {
            [defaults setObject:(NSString *)[dicJson objectForKey:@"content"] forKey:@"css"];
        }
        if ([api isEqualToString:@"get_css"]) {
            NSString *css = (NSString *)[defaults objectForKey:@"css"];
            if (css != nil) {
                responseCallback(css);
            }
        }
        if ([api isEqualToString:@"function_type"]) {
            NSString *function_name = (NSString *)[defaults objectForKey:@"function_name"];
            if (function_name == nil) {
                function_name = @"anh_viet";
            }
            responseCallback(function_name);
            if ([ [ UIScreen mainScreen ] bounds ].size.height > 480.0f) {
                //iphone 5
                [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('search_content').style.height = '400px';"];
            }
            else{
                //iphone 4
                [self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('search_content').style.height = '300px';"];
//                [webView stringByEvaluatingJavaScriptFromString:@"alert('iphone4')"];
            }
            BOOL showMenuIntro = [[NSUserDefaults standardUserDefaults] boolForKey:@"showMenuIntro"];
            if (!showMenuIntro) {
                [iKToast showToastWithString:@"Kéo sang phải để xem Menu" duration:5 withDistance:30 inPosition:iKToastPositionBottom];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showMenuIntro"];
            }
        }
        if ([api isEqualToString:@"save_bookmarks"]) {
            NSString *bookmarks = (NSString *)[defaults objectForKey:@"bookmarks"];
            if (bookmarks == nil) {
                bookmarks = @"";
                bookmarks = [bookmarks stringByAppendingFormat:@"%@",(NSString *)[dicJson objectForKey:@"keyword"]];
            }else{
                bookmarks = [bookmarks stringByAppendingFormat:@";%@",(NSString *)[dicJson objectForKey:@"keyword"]];
            }
            [defaults setObject:bookmarks forKey:@"bookmarks"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Bookmarks", nil)
                                                            message:NSLocalizedString(@"Bookmark successfully!", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
        if ([api isEqualToString:@"share_email"]) {
            [self onTapEmailWithSubject:[dicJson objectForKey:@"subject"] withMailTo:nil withMessageBody:[dicJson objectForKey:@"body"]];
        }
        if ([api isEqualToString:@"share_sms"]) {
            [self sendSMSFromTuDien:[dicJson objectForKey:@"content"]];
        }
        if ([api isEqualToString:@"gps"]) {
            [self gps_show];
        }
        if ([api isEqualToString:@"database"]) {
            //TU DIEN TRY: check database
            NSString *history = (NSString *)[defaults objectForKey:@"history"];
            if (history == nil) {
                history = @"";
                history = [history stringByAppendingFormat:@"%@-%@",(NSString *)[dicJson objectForKey:@"keyword"],(NSString *)[dicJson objectForKey:@"dbname"]];
            }else{
                history = [history stringByAppendingFormat:@";%@-%@",(NSString *)[dicJson objectForKey:@"keyword"],(NSString *)[dicJson objectForKey:@"dbname"]];
            }
            [defaults setObject:history forKey:@"history"];
            MNDatabaseManagement *database = [[MNDatabaseManagement alloc] init];
            NSInteger allowCounted = [[NSUserDefaults standardUserDefaults] integerForKey:@"allowCounted2"];
            if (allowCounted == 0) {
                allowCounted = 1;
            }else{
                allowCounted += 1;
            }
            [[NSUserDefaults standardUserDefaults] setInteger:allowCounted forKey:@"allowCounted2"];
//            NSLog(@" ********* allowCounted %d ***********",allowCounted);
//            if (allowCounted == 8) {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Review ứng dụng!"
//                                                                message:@"Hãy review 5 sao cho ứng dụng để giúp ứng dụng trở nên phổ biến hơn. Cảm ơn bạn!"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"Đồng ý"
//                                                      otherButtonTitles:@"No, thanks!",nil];
//                alert.tag = 102;
//                [alert show];
//            }
//            if (allowCounted%6 == 0) {
//                [self showAdvertising];
//            }
            responseCallback([database findKeyWordForManaDict:dicJson]);
            BOOL showTranslateIntro = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTranslateIntro"];
            if (!showTranslateIntro) {
                [iKToast showToastWithString:@"Tap vào từ màu xanh để xem tiếp" duration:5 withDistance:30 inPosition:iKToastPositionBottom];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"showTranslateIntro"];
            }
        }
    }];
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"Dictionary" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:appHtml baseURL:nil];
    [self performSelector:@selector(startCheckingDatabase) withObject:nil afterDelay:0.5];
}

- (void)startCheckingDatabase{
    //Start thread to download app
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *dictData = [documentRootPath stringByAppendingPathComponent:@"anh_viet.db"];
    NSString *zipFilePath = [documentRootPath stringByAppendingPathComponent:@"ava_dict_data.zip"];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:dictData]) {
        [self.loadingView setHidden:NO];
        [self.labelLoading setHidden:NO];
        [self.indicatorLoading setHidden:NO];
        [self.indicatorLoading startAnimating];
        dispatch_async(dispatch_queue_create("com.benjaminsoft.bgqueue", NULL), ^(void) {
            if (![manager fileExistsAtPath:zipFilePath]) {
                NSURL *urlZipDropBox = [NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/70353767/iOSapplist/dict.zip"];
                NSData *dataZip = [NSData dataWithContentsOfURL:urlZipDropBox];
                [dataZip writeToFile:zipFilePath atomically:YES];
            }
            [SSZipArchive unzipFileAtPath:zipFilePath toDestination:documentRootPath];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.loadingView setHidden:YES];
                [self.labelLoading setHidden:YES];
                [self.indicatorLoading setHidden:YES];
                [self.indicatorLoading stopAnimating];
                [self excludeFromBackup];
            });
        });
    }else{
        [self.loadingView setHidden:YES];
        [self.labelLoading setHidden:YES];
        [self.indicatorLoading setHidden:YES];
        [self.indicatorLoading stopAnimating];
        [self excludeFromBackup];
    }
}

- (void) excludeFromBackup {
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentRootPath = [documentPaths objectAtIndex:0];
    NSString *dictData = [documentRootPath stringByAppendingPathComponent:@"anh_viet.db"];
    NSString *zipFilePath = [documentRootPath stringByAppendingPathComponent:@"ava_dict_data.zip"];
    
    // Exclude these from Backup
    NSURL *urlDB = [[NSURL alloc] initFileURLWithPath:dictData];
    NSError *error;
    [urlDB setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    NSLog(error.description);
    
    NSURL *urlZip = [[NSURL alloc] initFileURLWithPath:zipFilePath];
    [urlZip setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    NSLog(error.description);
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alert.tag == 102) {
        if (buttonIndex != 1) {
            NSString* url = [[NSString alloc] initWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software", @"647566804"];
            NSString *urlTryApp = @"http://benjaminsoft.byethost14.com/web_service/Advertising/rating.php";
            NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
            NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
            NSString *urlRequest = [[NSString alloc] initWithFormat:@"%@?appname=Ava&usercountry=%@&apprating=1",urlTryApp,countryCode];
            NSLog(@"%@",urlRequest);
            [GetAdvertisingWebService getDataFromWebService:urlRequest withHandle:^(NSString* code, NSDictionary *data, NSError *error){
                NSLog(@"dont care return value");
                [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
            }];
        }
    }
}


-(void)gps_show
{
    MNGPS *controller = [[MNGPS alloc]init];
    NSString *data = [controller getGPS];
    UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 400, 100)];
    [yourLabel setTextColor:[UIColor blackColor]];
    [yourLabel setBackgroundColor:[UIColor clearColor]];
    [yourLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 14.0f]];
    [yourLabel setNumberOfLines:5];
    yourLabel.text=data;
    
    UIView *v=[[UIView alloc]initWithFrame:CGRectMake(0, 10, 300, 300)];
    [v setBackgroundColor:[UIColor whiteColor]];
    [v addSubview:yourLabel];
    [v viewWithTag:111];
    [self.view addSubview:v];
    //[self presentViewController:comp animated:YES completion:NULL];
}
- (void)onTapEmailWithSubject:(NSString*)_subject withMailTo:(NSArray*)_mailTo withMessageBody:(NSString*)_mess
{
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc setSubject:_subject];
    mc.mailComposeDelegate = self;
    [mc setMessageBody:_mess isHTML:NO];
    [mc setToRecipients:_mailTo];
    [self presentViewController:mc animated:YES completion:NULL];
}
//send SMS from API
- (void) sendSMSFromTuDien:(NSString *)content{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = content;
        controller.recipients = nil;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    MNGetFocusScreen *controller = [[MNGetFocusScreen alloc]init];
    [controller stateScreenWithScreenNumber:@"5"];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    NSLog(@"%@ willMoveToParentViewController %@", self, parent);
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    NSLog(@"%@ didMoveToParentViewController %@", self, parent);
}

#pragma mark showAdvertising
- (void)showAdvertising{
//    NSString *url = @"http://benjaminsoft.byethost14.com/web_service/Advertising/advertising.php?appname=Ava";
//    [GetAdvertisingWebService getDataFromWebService:url withHandle:^(NSString* code, NSDictionary *data, NSError *error){
//        dispatch_async(dispatch_queue_create("com.benjaminsoft.bgqueue", NULL), ^(void) {
//            NSString *title = [data objectNotNullForKey:@"appname"];
//            self.appNameToAdvertising = title;
//            self.appNameToAdvertising = [self.appNameToAdvertising stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
//            NSString *desc = [data objectNotNullForKey:@"appdesc"];
//            
//            NSURL *url1 = [NSURL URLWithString:[data objectNotNullForKey:@"url1"]];
//            NSData *data1 = [NSData dataWithContentsOfURL:url1];
//            UIImage *img1 = [[UIImage alloc] initWithData:data1];
//            
//            NSURL *url2 = [NSURL URLWithString:[data objectNotNullForKey:@"url2"]];
//            NSData *data2 = [NSData dataWithContentsOfURL:url2];
//            UIImage *img2 = [[UIImage alloc] initWithData:data2];
//            
//            NSURL *url3 = [NSURL URLWithString:[data objectNotNullForKey:@"url3"]];
//            NSData *data3 = [NSData dataWithContentsOfURL:url3];
//            UIImage *img3 = [[UIImage alloc] initWithData:data3];
//            if (img1 && img2 && img3) {
//                NSArray *imageList = [NSArray arrayWithObjects: img1, img2, img3, nil];
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    AdvertisingView *lplv = [[AdvertisingView alloc] initWithTitle:title options:imageList andDescription:desc handler:^(NSInteger anIndex) {
//                        
//                    }];
//                    lplv.appstore = [data objectNotNullForKey:@"appstore"];
//                    lplv.delegate = self;
//                    [lplv showInView:self.view.window animated:YES];
//                });
//            }
//            return;
//        });
//        
//    }];
    
}

- (void)agreeToTryApp:(NSString*)url{
//    NSString *urlTryApp = @"http://benjaminsoft.byethost14.com/web_service/Advertising/tryapp.php";
//    NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
//    NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
//    NSString *urlRequest = [[NSString alloc] initWithFormat:@"%@?appname=Ava&usercountry=%@&appadvertising=%@",urlTryApp,countryCode,self.appNameToAdvertising];
//    NSLog(@"%@",urlRequest);
//    [GetAdvertisingWebService getDataFromWebService:urlRequest withHandle:^(NSString* code, NSDictionary *data, NSError *error){
//        NSLog(@"dont care return value");
//        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
//    }];
}
- (void)noAgreeToTryApp:(int)type{
    
}

//- (void)dealloc {
//    [super dealloc];
//}
@end
