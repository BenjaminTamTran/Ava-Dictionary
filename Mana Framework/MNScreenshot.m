//
//  MNScreenshot.m
//  Mana Framework
//
//  Created by Tuan Truong Anh on 3/1/13.
//  Copyright (c) 2013 Song Vang. All rights reserved.
//

#import "MNScreenshot.h"
#import "MNFile.h"
#import <QuartzCore/QuartzCore.h>
@implementation MNScreenshot
- (NSString *) processRESTRequest:(NSString *)request{
    if ([request rangeOfString:@"save"].location != NSNotFound)
    {
        if ([[request componentsSeparatedByString:@"="][1] isEqualToString:@""]) {
            MNFile *datafile=[[MNFile alloc]init];
            [datafile saveimage:[self screenshot] :@""];
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",@"path=Document/"];
            return json_;
        }
        else
        {
            NSArray *queryElements = [request componentsSeparatedByString:@"?"];
            NSArray *queryElements1=[queryElements[1] componentsSeparatedByString:@"="];
            NSString *path=queryElements1[1];
            MNFile *datafile=[[MNFile alloc]init];
            [datafile saveimage:[self screenshot] :path];
            NSString *json_ = [[NSString alloc] initWithFormat:@"{\"Result\":\"%@\",\"Error\":\"%@\",\"Data\":\[\%@]}", @"200",@"",queryElements[1]];
            return json_;
        }
    }
    return @"[{\"Result\":\"Fail\",\"Error\":\"No action found\",}]";
}
- (UIImage*)screenshot
{
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
@end
