//
//  iKToast.m
//  testToast
//
//  Created by Firstiar Noorwinanto on 11/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "iKToast.h"
#import <QuartzCore/QuartzCore.h>
#import "MNAppDelegate.h"
@implementation iKToast

const iKToast *sharedInstance = nil;

#pragma mark -
@synthesize stack;
@synthesize duration, distance, position, stacked;

#pragma mark -
#pragma mark Singleton Code
+(iKToast*)sharedInstance {
    if (nil != sharedInstance) {
        return (iKToast*)sharedInstance;
    }
    
    /*//It should be thread safe ... but still have some error
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[super allocWithZone:NULL] init];
        //sharedInstance = [[iKToast alloc] init];
        sharedInstance.stack = [NSMutableArray array];
    });//*/
    
    sharedInstance = [[super allocWithZone:NULL] init];
    sharedInstance.stack = [NSMutableArray array];
    
    return (iKToast*)sharedInstance;
}

+(id)allocWithZone:(NSZone*)zone {
    return [[self sharedInstance] retain];
}

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

- (oneway void)release {
    
}

- (id)autorelease {
    return self;
}

-(void)dealloc {
    [stack release];
    [super dealloc];
}

#pragma mark -
#pragma mark Toast Manager Code
-(void)addToast:(UIView*)toastItem {
    [stack addObject:toastItem];
}

-(void)removeToast:(UIView*)toastItem {
    [stack removeObject:toastItem];
}

-(void)removeFirstToast {
    [stack removeObjectAtIndex:0];
}

-(NSInteger)toastCount {
    return [stack count];
}

#pragma mark -
#pragma mark Toast Code
+(void)rotateToStatusBarOrientation:(UIView*)view {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGFloat angle = 0.0;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown: 
            angle = M_PI;
            break;
            
        case UIInterfaceOrientationLandscapeLeft: 
            angle = - M_PI / 2.0f;
            break;
            
        case UIInterfaceOrientationLandscapeRight: 
            angle = M_PI / 2.0f;
            break;
            
        default: 
            angle = 0.0;
            break;
    }
    
    view.transform = CGAffineTransformMakeRotation(angle);
}

+(CGRect)adjustPositionWhenOrientationChange:(CGRect)frame inPosition:(iKToastPosition)position {
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	CGSize screenSize = [UIScreen mainScreen].bounds.size;
	float x, y, width, height;
	float screenWidth, screenHeight;
    CGFloat heightFromEdge = 0;
    if (position == iKToastPositionTop)
        heightFromEdge = frame.origin.y;
    else if (position == iKToastPositionBottom)
        heightFromEdge = screenSize.height - frame.size.height - frame.origin.y;
    
    switch (orientation) { 
        case UIInterfaceOrientationPortraitUpsideDown: 
            width = frame.size.width;
            height = frame.size.height;
			screenWidth = MIN(screenSize.width, screenSize.height);
			screenHeight = MAX(screenSize.width, screenSize.height);
			x = (screenWidth - frame.size.width) / 2.0f;
            if (position == iKToastPositionTop)
                y = screenHeight - frame.size.height - heightFromEdge;
            else if (position == iKToastPositionBottom)
                y = heightFromEdge;
            else if (position == iKToastPositionMiddle)
                y = (screenHeight - frame.size.height) / 2.0f;
            break;
            
        case UIInterfaceOrientationLandscapeLeft: 
            width = frame.size.height;
            height = frame.size.width;
			screenWidth = MAX(screenSize.width, screenSize.height);
			screenHeight = MIN(screenSize.width, screenSize.height);
            if (position == iKToastPositionTop)
                x = heightFromEdge;
            else if (position == iKToastPositionBottom)
                x = screenHeight - frame.size.height - heightFromEdge;
            else if (position == iKToastPositionMiddle)
                x = (screenHeight - frame.size.height) / 2.0f;
			y = (screenWidth - frame.size.width) / 2.0f;
            break;
            
        case UIInterfaceOrientationLandscapeRight: 
            width = frame.size.height;
            height = frame.size.width;
			screenWidth = MAX(screenSize.width, screenSize.height);
			screenHeight = MIN(screenSize.width, screenSize.height);
            if (position == iKToastPositionTop)
                x = screenHeight - frame.size.height - heightFromEdge;
            else if (position == iKToastPositionBottom)
                x = heightFromEdge;
            else if (position == iKToastPositionMiddle)
                x = (screenHeight - frame.size.height) / 2.0f;
			y = (screenWidth - frame.size.width) / 2.0f;
            break;
            
        default: 
            width = frame.size.width;
            height = frame.size.height;
			screenWidth = MIN(screenSize.width, screenSize.height);
			screenHeight = MAX(screenSize.width, screenSize.height);
			x = (screenWidth - frame.size.width) / 2.0f;
            if (position == iKToastPositionTop)
                y = heightFromEdge;
            else if (position == iKToastPositionBottom)
                y = screenHeight - frame.size.height - heightFromEdge;
            else if (position == iKToastPositionMiddle)
                y = (screenHeight - frame.size.height) / 2.0f;
            break;
            
    }
	return CGRectMake(x, y, width, height);
}

+(void)showToastWithString:(NSString*)message duration:(CGFloat)duration withDistance:(CGFloat)distance inPosition:(iKToastPosition)position {
    UIView *toastView = [iKToast getMessageView:message];
    [iKToast showToastWithView:toastView duration:duration withDistance:distance inPosition:position];
}

+(void)showToastWithView:(UIView*)toastView duration:(CGFloat)duration withDistance:(CGFloat)distance inPosition:(iKToastPosition)position {
    [toastView retain];
    
    MNAppDelegate *appDelegate = (MNAppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.toast = nil;
	appDelegate.toast = [[UIApplication sharedApplication] keyWindow];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    float width = 0;
    if (UIInterfaceOrientationIsPortrait(uiOrientation))
        width = screenSize.width - 20.0f;
    else
        width = screenSize.height - 20.0f;
    
    //calculate how many toast are they and adjust position
    NSInteger tag = 1412;
    
    CGSize size = toastView.frame.size;
    
    //calculate origin point for show and hide
    CGPoint origin = CGPointZero;
    origin.x = (screenSize.width - size.width) / 2;
    if (position == iKToastPositionBottom)
        origin.y = screenSize.height - (size.height) - distance;
    else if (position == iKToastPositionTop)
        origin.y = size.height + distance;
    else if (position == iKToastPositionMiddle)
        origin.y = (screenSize.height - size.height) / 2;

    CGRect showFrame = CGRectMake(origin.x, origin.y, size.width, size.height);
    CGRect hideFrame = CGRectZero;
    hideFrame.size = showFrame.size;
    hideFrame.origin.x = origin.x;
    if (position == iKToastPositionBottom)
        hideFrame.origin.y = screenSize.height;
    else if (position == iKToastPositionTop)
        hideFrame.origin.y = -size.height;
    
    //adjust for ui rotation
    [iKToast rotateToStatusBarOrientation:toastView];
    showFrame = [iKToast adjustPositionWhenOrientationChange:showFrame inPosition:position];
    hideFrame = [iKToast adjustPositionWhenOrientationChange:hideFrame inPosition:position];
    
    toastView.frame = hideFrame;
    //textLabel.layer.masksToBounds = YES;
    toastView.layer.cornerRadius = 5.0f;
    toastView.alpha = 0.0f;
    toastView.tag = tag;
    
	[appDelegate.toast addSubview:toastView];
    
    //animate it
    [UIView animateWithDuration:0.5 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         toastView.alpha = 0.8f;
                         toastView.frame = showFrame;
                     }
                     completion:^ (BOOL finished) {
                         //call a GCD function to delay the dismiss animation creation so the toast message
                         //still visible during duration before it dismiss animation commited if the iOS animation
                         //somehow bugged.
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*duration),
                                        dispatch_get_current_queue(), ^{
                                            [UIView animateWithDuration:0.5 
                                                                  delay:0
                                                                options:UIViewAnimationOptionAllowUserInteraction
                                                             animations:^ {
                                                                 toastView.alpha = 0.0f;
                                                                 toastView.frame = hideFrame;
                                                             }
                                                             completion:^ (BOOL finished) {
                                                                 [toastView removeFromSuperview];
                                                             }];
                                        });
                     }];
    
    //release the text label
    [toastView release];
}

-(void)toastItemFinished {
    //record the toast item frame values
    NSMutableArray *frames = [NSMutableArray array];
    for (UIView *item in stack) {
        [frames addObject:[NSValue valueWithCGRect:item.frame]];
    }
    //remove toast item
    UIView *item = [(UIView*)[stack objectAtIndex:0] retain];
    [[iKToast sharedInstance] removeToast:item];
    [UIView animateWithDuration:0.5 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^ {
                         item.alpha = 0.0f;
                         item.frame = hideFrame;
                     }
                     completion:^ (BOOL finished) {
                         [item removeFromSuperview];
                     }];
    //shift the remaining toast items
    int i = 0;
    for (UIView *item in stack) {
        [UIView animateWithDuration:0.5 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^ {
                             item.frame = [[frames objectAtIndex:i] CGRectValue];
                         }
                         completion:^ (BOOL finished) {
                         }];
        i++;
    }
    [item release];
}
-(void)showToastMessage:(NSString*)message {
    UIView *toastView = [iKToast getMessageView:message];
    [self showToastView:toastView];
}

-(void)showToastView:(UIView *)toastView {
    [toastView retain];
	UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    float width = 0;
    if (UIInterfaceOrientationIsPortrait(uiOrientation))
        width = screenSize.width - 20.0f;
    else
        width = screenSize.height - 20.0f;
    
    //calculate how many toast are they and adjust position
    NSInteger tag = 1412;
    NSInteger count = 0;
    if (stacked) {
        count = [[iKToast sharedInstance] toastCount];
    }
    
    CGSize size = toastView.frame.size;
    
    //calculate origin point for show and hide
    CGPoint origin = CGPointZero;
    origin.x = (screenSize.width - size.width) / 2;
    if (position == iKToastPositionBottom)
        origin.y = screenSize.height - (size.height * (count + 1)) - distance;
    else if (position == iKToastPositionTop)
        origin.y = (size.height * (count + 1)) + distance;
    
    showFrame = CGRectMake(origin.x, origin.y, size.width, size.height);
    hideFrame = CGRectZero;
    hideFrame.size = showFrame.size;
    hideFrame.origin.x = origin.x;
    if (position == iKToastPositionBottom)
        hideFrame.origin.y = screenSize.height;
    else if (position == iKToastPositionTop)
        hideFrame.origin.y = -size.height;
    
    //adjust for ui rotation
    [iKToast rotateToStatusBarOrientation:toastView];
    showFrame = [iKToast adjustPositionWhenOrientationChange:showFrame inPosition:position];
    hideFrame = [iKToast adjustPositionWhenOrientationChange:hideFrame inPosition:position];
    
    toastView.frame = hideFrame;
    //textLabel.layer.masksToBounds = YES;
    toastView.layer.cornerRadius = 5.0f;
    toastView.alpha = 0.0f;
    toastView.tag = tag;
    
	[mainWindow addSubview:toastView];
    [[iKToast sharedInstance] addToast:toastView];
    
    //animate it
    [UIView animateWithDuration:0.5 
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^ {
                         toastView.alpha = 0.8f;
                         toastView.frame = showFrame;
                     }
                     completion:^ (BOOL finished) {
                         [self performSelector:@selector(toastItemFinished) withObject:nil afterDelay:duration];
                     }];
    
    //release the text label
    [toastView release];
}

+(UIView*)getMessageView:(NSString *)message {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    UIInterfaceOrientation uiOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    float width = 0;
    if (UIInterfaceOrientationIsPortrait(uiOrientation))
        width = screenSize.width - 20.0f;
    else
        width = screenSize.height - 20.0f;
    
    //create text label
	UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = message;
	textLabel.backgroundColor = [UIColor blackColor];
	textLabel.textAlignment = UITextAlignmentCenter;
	textLabel.font = [UIFont systemFontOfSize:14];
	textLabel.textColor = [UIColor whiteColor];
	textLabel.numberOfLines = 0;
	textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    //calculate size
    CGSize size = [message sizeWithFont:textLabel.font
                      constrainedToSize:CGSizeMake(width - 20.0f, 9999.0f)
                          lineBreakMode:textLabel.lineBreakMode];
    CGRect frame = textLabel.frame;
    frame.size.width = size.width + 20.0f;
    frame.size.height = size.height + 6.0f;
    textLabel.frame = frame;
    
    return [textLabel autorelease];
}

@end
